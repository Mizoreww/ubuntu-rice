# gnome-settings.sh - GNOME desktop appearance and font settings module
# Sourced by install.sh; do not execute directly.

gnome_settings_name="GNOME Settings"
gnome_settings_desc="Desktop appearance and font settings"

gnome_settings_check() {
    command -v gsettings &>/dev/null
}

gnome_settings_supported() {
    local ver="$1"
    case "$ver" in
        20.04|22.04|24.04) return 0 ;;
        *) return 1 ;;
    esac
}

gnome_settings_install() {
    local ver="$1"

    log_info "Installing dconf-cli..."
    pkg_install dconf-cli
    log_success "dconf-cli installed"
}

gnome_settings_uninstall() {
    # Do not remove system settings tools
    log_info "GNOME settings module has no packages to remove"
    return 0
}

gnome_settings_apply_config() {
    local config_src="$1"

    log_info "Applying GNOME desktop settings..."

    # Apply settings via gsettings
    gsettings set org.gnome.desktop.interface icon-theme 'Tela-blue'
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    gsettings set org.gnome.desktop.interface cursor-size 48
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
    gsettings set org.gnome.desktop.interface font-name 'Ubuntu Sans 11'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Sans Mono 13'

    # Load dconf dumps if available
    if [ -f "$config_src/gnome-interface.dconf" ]; then
        log_info "Loading GNOME interface dconf settings..."
        dconf load /org/gnome/desktop/interface/ < "$config_src/gnome-interface.dconf"
    fi

    if [ -f "$config_src/gnome-wm.dconf" ]; then
        log_info "Loading GNOME WM dconf settings..."
        dconf load /org/gnome/desktop/wm/preferences/ < "$config_src/gnome-wm.dconf"
    fi

    log_success "GNOME desktop settings applied"
}
