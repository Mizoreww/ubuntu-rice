#!/bin/bash
# install.sh - Main entry point for ubuntu-rice
set -e

# ── Resolve project directory ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DIR="$SCRIPT_DIR"

# ── Source libraries ─────────────────────────────────────────────────────
source "${PROJECT_DIR}/lib/utils.sh"
source "${PROJECT_DIR}/lib/distro.sh"
source "${PROJECT_DIR}/lib/tui.sh"

# ── Preflight checks ────────────────────────────────────────────────────

# Do not run as root
if [[ "$EUID" -eq 0 ]]; then
    log_error "Do not run this script as root. Run as a normal user (sudo will be requested when needed)."
    exit 1
fi

# Ensure whiptail is available
if ! command -v whiptail &>/dev/null; then
    log_info "whiptail not found, installing..."
    sudo apt-get update -qq && sudo apt-get install -y whiptail
fi

# ── Detect system ────────────────────────────────────────────────────────
UBUNTU_VERSION="$(detect_ubuntu_version)"
GNOME_VERSION="$(detect_gnome_version)"

if [[ "$UBUNTU_VERSION" == "unsupported" ]]; then
    log_error "Unsupported Ubuntu version. This tool supports 20.04, 22.04, and 24.04."
    exit 1
fi

log_info "Detected Ubuntu ${UBUNTU_VERSION}, GNOME ${GNOME_VERSION}"

# ── Module loading ───────────────────────────────────────────────────────
# Associative arrays for module metadata
declare -a MODULE_IDS=()        # ordered list of module IDs
declare -A MODULE_NAMES=()      # module_id -> human-friendly name
declare -A MODULE_DESCS=()      # module_id -> short description
declare -A MODULE_SUPPORTED=()  # module_id -> "yes" or reason string

# Load every modules/*.sh file
if [[ -d "${PROJECT_DIR}/modules" ]]; then
    for mod_file in "${PROJECT_DIR}"/modules/*.sh; do
        [[ -f "$mod_file" ]] || continue

        # Extract module ID from filename: ghostty.sh -> ghostty
        # Convert hyphens to underscores (bash functions cannot contain hyphens)
        mod_id="$(basename "$mod_file" .sh)"
        mod_id="${mod_id//-/_}"

        # Source the module (defines ${mod_id}_name, ${mod_id}_desc, etc.)
        source "$mod_file"

        MODULE_IDS+=("$mod_id")

        # Populate name and description via variable indirect reference
        # NOTE: do not use `local` here — this loop runs in the script body,
        # not inside a function, so `local` would error under `set -e`.
        name_var="${mod_id}_name"
        desc_var="${mod_id}_desc"
        MODULE_NAMES["$mod_id"]="${!name_var:-$mod_id}"
        MODULE_DESCS["$mod_id"]="${!desc_var:-}"

        # Check version support
        if declare -f "${mod_id}_supported" &>/dev/null; then
            if "${mod_id}_supported" "$UBUNTU_VERSION" 2>/dev/null; then
                MODULE_SUPPORTED["$mod_id"]="yes"
            else
                MODULE_SUPPORTED["$mod_id"]="unsupported on ${UBUNTU_VERSION}"
            fi
        else
            MODULE_SUPPORTED["$mod_id"]="yes"
        fi
    done
fi

if [[ ${#MODULE_IDS[@]} -eq 0 ]]; then
    log_warn "No modules found in modules/ directory."
    exit 0
fi

# ── Welcome banner ───────────────────────────────────────────────────────
print_banner "Ubuntu Rice Installer"
log_info "Found ${#MODULE_IDS[@]} module(s)"

# ── Build TUI checklist ─────────────────────────────────────────────────
checklist_items=()
for mod_id in "${MODULE_IDS[@]}"; do
    local_name="${MODULE_NAMES[$mod_id]}"
    local_desc="${MODULE_DESCS[$mod_id]}"
    local_support="${MODULE_SUPPORTED[$mod_id]}"

    if [[ "$local_support" == "yes" ]]; then
        tag="$mod_id"
        desc="${local_name} - ${local_desc}"
        checklist_items+=("$tag" "$desc" "ON")
    else
        tag="$mod_id"
        desc="${local_name} [N/A: ${local_support}]"
        checklist_items+=("$tag" "$desc" "OFF")
    fi
done

selected="$(tui_checklist "Select Components" "${checklist_items[@]}")" || {
    log_info "Cancelled by user."
    exit 0
}

if [[ -z "$selected" ]]; then
    log_info "No components selected."
    exit 0
fi

# ── Confirmation ─────────────────────────────────────────────────────────
tui_yesno "Confirm Installation" "The following will be installed:\n\n${selected}\n\nProceed?" || {
    log_info "Cancelled by user."
    exit 0
}

# ── Install selected modules ────────────────────────────────────────────
results=()
for mod_id in $selected; do
    log_info "────── Installing: ${MODULE_NAMES[$mod_id]} ──────"

    # install()
    if declare -f "${mod_id}_install" &>/dev/null; then
        if "${mod_id}_install" "$UBUNTU_VERSION"; then
            log_success "${MODULE_NAMES[$mod_id]} installed."

            # apply_config() if configs exist
            if declare -f "${mod_id}_apply_config" &>/dev/null; then
                config_dir="$(get_config_dir "$mod_id" || true)"
                if [[ -n "$config_dir" ]]; then
                    log_info "Applying config from: $config_dir"
                    "${mod_id}_apply_config" "$config_dir"
                fi
            fi

            results+=("${MODULE_NAMES[$mod_id]}:ok")
        else
            log_error "Failed to install ${MODULE_NAMES[$mod_id]}"
            results+=("${MODULE_NAMES[$mod_id]}:fail")
        fi
    else
        log_warn "Module $mod_id has no install function, skipping."
        results+=("${MODULE_NAMES[$mod_id]}:fail")
    fi
done

# ── Results summary ──────────────────────────────────────────────────────
tui_show_result "${results[@]}"

# ── Post-install hints ───────────────────────────────────────────────────
print_banner "Installation Complete"
log_info "You may need to:"
log_info "  - Log out and log back in for some changes to take effect"
log_info "  - Restart GNOME Shell (Alt+F2 -> r -> Enter) on X11"
log_info "  - Reboot for kernel-level changes"
echo ""
log_success "Enjoy your rice!"
