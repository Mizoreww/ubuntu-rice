# theme.sh - GTK theme, icons, and cursor module
# Sourced by install.sh; do not execute directly.

theme_name="GTK Theme & Icons"
theme_desc="Orchis GTK, Tela icons, Bibata cursor"

theme_check() {
    test -d ~/.themes/Orchis -o -d ~/.icons/Tela-blue
}

theme_supported() {
    local ver="$1"
    case "$ver" in
        20.04|22.04|24.04) return 0 ;;
        *) return 1 ;;
    esac
}

theme_install() {
    local ver="$1"

    mkdir -p ~/.themes ~/.icons

    # Orchis GTK Theme
    if [ ! -d ~/.themes/Orchis ]; then
        log_info "Installing Orchis GTK theme..."
        local tmpdir
        tmpdir=$(mktemp -d)
        git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git "$tmpdir/Orchis-theme"
        (cd "$tmpdir/Orchis-theme" && ./install.sh -d ~/.themes)
        rm -rf "$tmpdir"
    else
        log_success "Orchis GTK theme already installed"
    fi

    # Tela Icon Theme
    if [ ! -d ~/.icons/Tela-blue ]; then
        log_info "Installing Tela icon theme..."
        local tmpdir
        tmpdir=$(mktemp -d)
        git clone --depth=1 https://github.com/vinceliuice/Tela-icon-theme.git "$tmpdir/Tela-icon-theme"
        (cd "$tmpdir/Tela-icon-theme" && ./install.sh -d ~/.icons blue)
        rm -rf "$tmpdir"
    else
        log_success "Tela icon theme already installed"
    fi

    # Bibata Cursor
    if [ ! -d ~/.icons/Bibata-Modern-Ice ]; then
        log_info "Installing Bibata cursor theme..."
        local tmpdir
        tmpdir=$(mktemp -d)
        wget -q -P "$tmpdir" https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
        tar -xf "$tmpdir/Bibata-Modern-Ice.tar.xz" -C ~/.icons/
        rm -rf "$tmpdir"
    else
        log_success "Bibata cursor already installed"
    fi

    log_success "Theme installation complete"
}

theme_uninstall() {
    log_info "Removing themes and icons..."
    rm -rf ~/.themes/Orchis*
    rm -rf ~/.icons/Tela-blue*
    rm -rf ~/.icons/Bibata-Modern-Ice
    log_success "Themes and icons removed"
}

theme_apply_config() {
    local config_src="$1"
    # Theme is applied via gnome-settings module (gsettings)
    return 0
}
