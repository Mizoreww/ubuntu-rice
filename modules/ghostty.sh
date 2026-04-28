# ghostty.sh - Ghostty Terminal module
# Modern GPU-accelerated terminal emulator with TokyoNight Moon theme

ghostty_name="Ghostty Terminal"
ghostty_desc="Fast, native, GPU-accelerated terminal (Mitchell Hashimoto)"

# Check if Ghostty is installed
ghostty_check() {
    command -v ghostty &>/dev/null
}

# Ghostty supports Ubuntu 22.04+ via the community PPA;
# 20.04 falls back to a manual build hint.
ghostty_supported() {
    local ver="$1"
    case "$ver" in
        22.04|24.04) return 0 ;;
        20.04)       return 1 ;;
        *)           return 0 ;;
    esac
}

# Install Ghostty via the community PPA (mkasberg/ghostty)
ghostty_install() {
    local ver="$1"

    if ghostty_check; then
        log_warn "Ghostty is already installed"
        return 0
    fi

    log_info "Installing Ghostty terminal..."

    # Ensure prerequisites for add-apt-repository
    if ! command -v add-apt-repository &>/dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y software-properties-common
    fi

    # Community-maintained PPA for Ubuntu 22.04 / 24.04
    sudo add-apt-repository -y ppa:mkasberg/ghostty
    sudo apt-get update -qq
    sudo apt-get install -y ghostty

    log_success "Ghostty terminal installed"
}

# Uninstall Ghostty
ghostty_uninstall() {
    log_info "Uninstalling Ghostty terminal..."

    sudo apt-get remove -y ghostty 2>/dev/null || true

    # Remove the PPA only if it was added by us; ignore errors if absent
    if command -v add-apt-repository &>/dev/null; then
        sudo add-apt-repository -y --remove ppa:mkasberg/ghostty 2>/dev/null || true
    fi

    log_success "Ghostty terminal uninstalled"
}

# Apply Ghostty configuration files
ghostty_apply_config() {
    local config_src="$1"

    log_info "Applying Ghostty configuration..."
    mkdir -p ~/.config/ghostty
    cp "$config_src"/config ~/.config/ghostty/ 2>/dev/null || true
    log_success "Ghostty configuration applied"
}
