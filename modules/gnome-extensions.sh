# gnome-extensions.sh - GNOME Extensions module
# Sourced by install.sh; do not execute directly.

gnome_extensions_name="GNOME Extensions"
gnome_extensions_desc="Extension Manager and recommended extensions"

gnome_extensions_check() {
    dpkg -l gnome-shell-extension-manager &>/dev/null
}

gnome_extensions_supported() {
    local ver="$1"
    case "$ver" in
        20.04|22.04|24.04) return 0 ;;
        *) return 1 ;;
    esac
}

gnome_extensions_install() {
    local ver="$1"

    log_info "Installing GNOME Tweaks..."
    pkg_install gnome-tweaks

    # gnome-shell-extension-manager may not be available on 20.04
    case "$ver" in
        20.04)
            log_warn "Extension Manager may not be available on 20.04, use GNOME Extensions website instead"
            pkg_install gnome-shell-extensions || true
            ;;
        22.04|24.04)
            log_info "Installing Extension Manager..."
            pkg_install gnome-shell-extension-manager
            ;;
    esac

    # Print recommended extensions
    log_info "Recommended GNOME extensions:"
    echo "  1. Blur my Shell   - https://extensions.gnome.org/extension/3193/blur-my-shell/"
    echo "  2. Dash to Dock    - https://extensions.gnome.org/extension/307/dash-to-dock/"
    echo "  3. Just Perfection - https://extensions.gnome.org/extension/3843/just-perfection/"
    echo "  4. User Themes     - https://extensions.gnome.org/extension/19/user-themes/"
    log_info "Install them via Extension Manager or extensions.gnome.org"

    log_success "GNOME Extensions setup complete"
}

gnome_extensions_uninstall() {
    log_info "Removing GNOME Extensions tools..."
    sudo apt-get remove -y gnome-shell-extension-manager gnome-tweaks
    log_success "GNOME Extensions tools removed"
}

gnome_extensions_apply_config() {
    local config_src="$1"

    if [ -f "$config_src/gnome-extensions.dconf" ]; then
        log_info "Loading GNOME extensions dconf settings..."
        dconf load /org/gnome/shell/extensions/ < "$config_src/gnome-extensions.dconf"
        log_success "GNOME extensions settings applied"
    else
        log_info "No gnome-extensions.dconf found, skipping"
    fi
}
