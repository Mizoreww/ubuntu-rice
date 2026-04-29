# fcitx5.sh - Fcitx5 input method module
# Sourced by install.sh; do not execute directly.

fcitx5_name="Fcitx5 Input Method"
fcitx5_desc="Chinese input method framework with Material theme"

fcitx5_check() {
    dpkg -l fcitx5 &>/dev/null
}

fcitx5_supported() {
    local ver="$1"
    case "$ver" in
        20.04)
            # fcitx5 not in official repos for 20.04, available via PPA
            return 0
            ;;
        22.04|24.04)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

fcitx5_install() {
    local ver="$1"

    if fcitx5_check; then
        log_success "Fcitx5 is already installed"
        return 0
    fi

    if [ "$ver" = "20.04" ]; then
        log_info "Adding Fcitx5 PPA for Ubuntu 20.04..."
        need_ppa "ppa:nicothin/fcitx5"
        sudo apt-get update -qq
    fi

    log_info "Installing Fcitx5 and addons..."
    pkg_install fcitx5 fcitx5-chinese-addons fcitx5-material-color fcitx5-config-qt
    log_success "Fcitx5 installed successfully"
}

fcitx5_uninstall() {
    log_info "Removing Fcitx5..."
    sudo apt-get remove -y fcitx5 fcitx5-chinese-addons fcitx5-material-color fcitx5-config-qt
    log_success "Fcitx5 removed"
}

fcitx5_apply_config() {
    local config_src="$1"

    log_info "Applying Fcitx5 configuration..."
    mkdir -p ~/.config/fcitx5/conf

    # Copy every *.conf shipped with the module — covers classicui, pinyin,
    # chttrans, notifications, punctuation, and any future additions.
    for f in "$config_src"/*.conf; do
        [ -f "$f" ] || continue
        cp "$f" ~/.config/fcitx5/conf/
        log_info "  + $(basename "$f")"
    done

    # Restart fcitx5 if running
    if pidof fcitx5 >/dev/null 2>&1; then
        fcitx5 -r -d 2>/dev/null &
        log_info "Fcitx5 restarted"
    fi

    log_success "Fcitx5 configuration applied"
}
