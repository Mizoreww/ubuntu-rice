#!/bin/bash
# uninstall.sh - Uninstall selected ubuntu-rice components
set -e

# ── Resolve project directory ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DIR="$SCRIPT_DIR"

# ── Source libraries ─────────────────────────────────────────────────────
source "${PROJECT_DIR}/lib/utils.sh"
source "${PROJECT_DIR}/lib/distro.sh"
source "${PROJECT_DIR}/lib/tui.sh"

# ── Preflight checks ────────────────────────────────────────────────────
if [[ "$EUID" -eq 0 ]]; then
    log_error "Do not run this script as root."
    exit 1
fi

if ! command -v whiptail &>/dev/null; then
    log_error "whiptail is required. Install it with: sudo apt install whiptail"
    exit 1
fi

# ── Load modules and detect installed ones ───────────────────────────────
declare -a MODULE_IDS=()
declare -A MODULE_NAMES=()
declare -A MODULE_DESCS=()
declare -a INSTALLED_IDS=()

if [[ -d "${PROJECT_DIR}/modules" ]]; then
    for mod_file in "${PROJECT_DIR}"/modules/*.sh; do
        [[ -f "$mod_file" ]] || continue

        mod_id="$(basename "$mod_file" .sh)"
        mod_id="${mod_id//-/_}"
        source "$mod_file"
        MODULE_IDS+=("$mod_id")

        # NOTE: do not use `local` here — this loop runs in the script body,
        # not inside a function, so `local` would error under `set -e`.
        name_var="${mod_id}_name"
        desc_var="${mod_id}_desc"
        MODULE_NAMES["$mod_id"]="${!name_var:-$mod_id}"
        MODULE_DESCS["$mod_id"]="${!desc_var:-}"

        # Check if the module is currently installed
        if declare -f "${mod_id}_check" &>/dev/null; then
            if "${mod_id}_check" &>/dev/null; then
                INSTALLED_IDS+=("$mod_id")
            fi
        fi
    done
fi

if [[ ${#INSTALLED_IDS[@]} -eq 0 ]]; then
    log_info "No installed components detected."
    tui_msgbox "Nothing to Uninstall" "No ubuntu-rice components are currently installed."
    exit 0
fi

# ── Build checklist of installed components ──────────────────────────────
checklist_items=()
for mod_id in "${INSTALLED_IDS[@]}"; do
    local_name="${MODULE_NAMES[$mod_id]}"
    local_desc="${MODULE_DESCS[$mod_id]}"
    checklist_items+=("$mod_id" "${local_name} - ${local_desc}" "OFF")
done

selected="$(tui_checklist "Select Components to Uninstall" "${checklist_items[@]}")" || {
    log_info "Cancelled by user."
    exit 0
}

if [[ -z "$selected" ]]; then
    log_info "No components selected."
    exit 0
fi

# ── Confirmation ─────────────────────────────────────────────────────────
tui_yesno "Confirm Uninstall" "The following will be REMOVED:\n\n${selected}\n\nProceed?" || {
    log_info "Cancelled by user."
    exit 0
}

# ── Uninstall selected modules ───────────────────────────────────────────
results=()
for mod_id in $selected; do
    log_info "────── Uninstalling: ${MODULE_NAMES[$mod_id]} ──────"

    if declare -f "${mod_id}_uninstall" &>/dev/null; then
        if "${mod_id}_uninstall"; then
            log_success "${MODULE_NAMES[$mod_id]} uninstalled."
            results+=("${MODULE_NAMES[$mod_id]}:ok")
        else
            log_error "Failed to uninstall ${MODULE_NAMES[$mod_id]}"
            results+=("${MODULE_NAMES[$mod_id]}:fail")
        fi
    else
        log_warn "Module $mod_id has no uninstall function, skipping."
        results+=("${MODULE_NAMES[$mod_id]}:fail")
    fi
done

# ── Results summary ──────────────────────────────────────────────────────
tui_show_result "${results[@]}"

print_banner "Uninstall Complete"
log_success "Done."
