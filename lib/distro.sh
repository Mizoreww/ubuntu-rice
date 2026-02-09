#!/bin/bash
# distro.sh - Ubuntu version detection and package helpers
# Sourced by install.sh; do not execute directly.

# ── detect_ubuntu_version ────────────────────────────────────────────────
# Prints one of: 20.04, 22.04, 24.04, or "unsupported".
detect_ubuntu_version() {
    local version=""

    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        version="${VERSION_ID:-}"
    elif command -v lsb_release &>/dev/null; then
        version="$(lsb_release -rs 2>/dev/null)"
    fi

    case "$version" in
        20.04|22.04|24.04)
            echo "$version"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# ── detect_gnome_version ─────────────────────────────────────────────────
# Prints the major GNOME Shell version (e.g. "42", "46"), or "unknown".
detect_gnome_version() {
    if command -v gnome-shell &>/dev/null; then
        local raw
        raw="$(gnome-shell --version 2>/dev/null)"
        # "GNOME Shell 42.9" -> "42"
        echo "$raw" | grep -oP '\d+' | head -1
    else
        echo "unknown"
    fi
}

# ── pkg_install ──────────────────────────────────────────────────────────
# Install one or more packages via apt. Logs progress.
pkg_install() {
    if [[ $# -eq 0 ]]; then
        log_warn "pkg_install called with no arguments"
        return 1
    fi
    log_info "Installing packages: $*"
    sudo apt-get install -y "$@" 2>&1 | tail -1
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        log_success "Packages installed: $*"
    else
        log_error "Failed to install: $*"
        return 1
    fi
}

# ── need_ppa ─────────────────────────────────────────────────────────────
# Add a PPA only if it is not already present.
# Usage: need_ppa "ppa:user/repo"
need_ppa() {
    local ppa="$1"
    # Strip the "ppa:" prefix to check the sources list
    local ppa_name="${ppa#ppa:}"

    if grep -rq "${ppa_name}" /etc/apt/sources.list.d/ 2>/dev/null; then
        log_info "PPA already present: $ppa"
        return 0
    fi

    log_info "Adding PPA: $ppa"
    sudo add-apt-repository -y "$ppa" 2>&1 | tail -1
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        log_success "PPA added: $ppa"
        sudo apt-get update -qq
    else
        log_error "Failed to add PPA: $ppa"
        return 1
    fi
}
