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
    else
        log_info "Installing Ghostty terminal..."

        # Ensure prerequisites for add-apt-repository
        if ! command -v add-apt-repository &>/dev/null; then
            sudo apt-get update -qq
            sudo apt-get install -y software-properties-common
        fi

        # Community-maintained PPA for Ubuntu 22.04 / 24.04
        if ! sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu; then
            log_error "Failed to add ppa:mkasberg/ghostty-ubuntu (network/sudo issue?)"
            return 1
        fi
        sudo apt-get update -qq
        # python3-nautilus enables ghostty's bundled "Open in Ghostty" right-click
        # extension at /usr/share/nautilus-python/extensions/ghostty.py.
        # xclip / wl-clipboard let TUI apps (e.g. Claude Code) reach the system
        # clipboard on X11 / Wayland — without them most Node/Electron CLIs
        # silently lose copy/paste.
        if ! sudo apt-get install -y ghostty python3-nautilus xclip wl-clipboard; then
            log_error "apt-get install ghostty failed — PPA may not have a build for ${ver}"
            return 1
        fi

        # Drop the gnome-terminal Nautilus extension if present — otherwise
        # right-click shows two "Open in Terminal" entries.
        if dpkg -l nautilus-extension-gnome-terminal &>/dev/null; then
            sudo apt-get remove -y nautilus-extension-gnome-terminal || true
        fi

        log_success "Ghostty terminal installed"
    fi

    # Register ghostty as the system's preferred x-terminal-emulator and
    # GNOME default terminal so launchers (and Files → "Open in Terminal")
    # use it instead of gnome-terminal.
    if command -v ghostty &>/dev/null; then
        if command -v update-alternatives &>/dev/null; then
            log_info "Registering ghostty with update-alternatives..."
            sudo update-alternatives --install /usr/bin/x-terminal-emulator \
                x-terminal-emulator "$(command -v ghostty)" 60 2>/dev/null || true
            sudo update-alternatives --set x-terminal-emulator "$(command -v ghostty)" 2>/dev/null || true
        fi

        # GNOME 42+ uses this gsetting; older versions silently ignore it.
        if command -v gsettings &>/dev/null; then
            gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty' 2>/dev/null || true
            gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e' 2>/dev/null || true
        fi

        log_success "Ghostty set as default terminal"
    fi
}

# Uninstall Ghostty
ghostty_uninstall() {
    log_info "Uninstalling Ghostty terminal..."

    sudo apt-get remove -y ghostty 2>/dev/null || true

    # Remove the PPA only if it was added by us; ignore errors if absent
    if command -v add-apt-repository &>/dev/null; then
        sudo add-apt-repository -y --remove ppa:mkasberg/ghostty-ubuntu 2>/dev/null || true
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
