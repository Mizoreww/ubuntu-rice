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

    if ! fcitx5_check; then
        if [ "$ver" = "20.04" ]; then
            log_info "Adding Fcitx5 PPA for Ubuntu 20.04..."
            need_ppa "ppa:nicothin/fcitx5"
            sudo apt-get update -qq
        fi

        log_info "Installing Fcitx5 and addons..."
        pkg_install fcitx5 fcitx5-chinese-addons fcitx5-material-color fcitx5-config-qt
    else
        log_success "Fcitx5 packages already installed"
    fi

    # Register fcitx5 as the active IM framework (user-level; writes ~/.xinputrc)
    if command -v im-config &>/dev/null; then
        log_info "Registering fcitx5 via im-config..."
        im-config -n fcitx5 >/dev/null 2>&1 || true
    fi

    # Add a fcitx5 autostart entry so it launches on login
    log_info "Installing fcitx5 autostart entry..."
    mkdir -p "$HOME/.config/autostart"
    cat > "$HOME/.config/autostart/fcitx5.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx 5
GenericName=Input Method
Comment=Start Input Method
Exec=fcitx5 -d
Icon=fcitx
Terminal=false
Categories=System;Utility;
StartupNotify=false
X-GNOME-Autostart-Phase=Applications
X-GNOME-AutoRestart=false
X-GNOME-Autostart-Notify=false
X-KDE-autostart-after=panel
EOF

    # Make sure fcitx5/pinyin is listed in GNOME input-sources alongside the
    # existing keyboard layout — without this the IM stays inactive even with
    # everything else configured.
    if command -v dconf &>/dev/null; then
        local current
        current="$(dconf read /org/gnome/desktop/input-sources/sources 2>/dev/null || echo '')"
        if [[ "$current" != *"'fcitx'"* && "$current" != *"'pinyin'"* ]]; then
            log_info "Adding ('fcitx', 'pinyin') to GNOME input-sources..."
            if [[ -z "$current" || "$current" == "@a(ss) []" ]]; then
                dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('fcitx', 'pinyin')]"
            else
                local merged="${current%]}, ('fcitx', 'pinyin')]"
                dconf write /org/gnome/desktop/input-sources/sources "$merged"
            fi
        fi
    fi

    # Start fcitx5 right now so the user does not need to log out
    if ! pgrep -x fcitx5 >/dev/null 2>&1; then
        log_info "Launching fcitx5 daemon..."
        nohup fcitx5 -d >/dev/null 2>&1 &
        disown 2>/dev/null || true
    fi

    log_success "Fcitx5 installed and configured"
    log_info "Switch IM with Ctrl+Space (or via the panel indicator)"
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
