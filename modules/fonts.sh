# fonts.sh - Nerd Fonts module
# MesloLGS NF font family for terminal and Powerlevel10k

fonts_name="Nerd Fonts"
fonts_desc="MesloLGS NF font family for terminal"

# Check if MesloLGS NF fonts are installed
fonts_check() {
    test -f ~/.local/share/fonts/"MesloLGS NF Regular.ttf"
}

# Fonts support all Ubuntu versions
fonts_supported() {
    return 0
}

# Download and install MesloLGS NF font family
fonts_install() {
    local ver="$1"

    if fonts_check; then
        log_warn "MesloLGS NF fonts are already installed"
        return 0
    fi

    log_info "Installing MesloLGS NF fonts..."
    mkdir -p ~/.local/share/fonts

    local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    for style in "Regular" "Bold" "Italic" "Bold Italic"; do
        local encoded
        encoded=$(echo "MesloLGS NF ${style}.ttf" | sed 's/ /%20/g')
        log_info "Downloading MesloLGS NF ${style}..."
        wget -q -P ~/.local/share/fonts/ "${base_url}/${encoded}"
    done

    log_info "Updating font cache..."
    fc-cache -fv

    log_success "MesloLGS NF fonts installed"
}

# Remove MesloLGS NF fonts
fonts_uninstall() {
    log_info "Removing MesloLGS NF fonts..."

    rm -f ~/.local/share/fonts/MesloLGS*
    fc-cache -fv

    log_success "MesloLGS NF fonts removed"
}

# No additional configuration needed for fonts
fonts_apply_config() {
    return 0
}
