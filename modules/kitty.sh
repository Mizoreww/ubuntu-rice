# kitty.sh - Kitty Terminal module
# GPU-accelerated terminal emulator with Tokyo Night theme

kitty_name="Kitty Terminal"
kitty_desc="GPU-accelerated terminal with Tokyo Night theme"

# Check if Kitty is installed
kitty_check() {
    command -v kitty &>/dev/null
}

# Kitty supports all Ubuntu versions
kitty_supported() {
    return 0
}

# Install Kitty via official installer
kitty_install() {
    local ver="$1"

    if kitty_check; then
        log_warn "Kitty is already installed"
        return 0
    fi

    log_info "Installing Kitty terminal..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # Create symlinks in ~/.local/bin
    log_info "Creating symlinks..."
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
    ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten

    # Create desktop launcher entries
    log_info "Setting up desktop launcher..."
    mkdir -p ~/.local/share/applications
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

    # Patch launcher to support input methods (ibus)
    sed -i 's|^Exec=.*kitty$|Exec=env GLFW_IM_MODULE=ibus '"$HOME"'/.local/kitty.app/bin/kitty|' \
        ~/.local/share/applications/kitty.desktop

    update-desktop-database ~/.local/share/applications/

    log_success "Kitty terminal installed"
}

# Uninstall Kitty and all related files
kitty_uninstall() {
    log_info "Uninstalling Kitty terminal..."

    rm -rf ~/.local/kitty.app
    rm -f ~/.local/bin/kitty
    rm -f ~/.local/bin/kitten
    rm -f ~/.local/share/applications/kitty.desktop
    rm -f ~/.local/share/applications/kitty-open.desktop

    log_success "Kitty terminal uninstalled"
}

# Apply Kitty configuration files
kitty_apply_config() {
    local config_src="$1"

    log_info "Applying Kitty configuration..."
    mkdir -p ~/.config/kitty
    cp "$config_src"/kitty.conf ~/.config/kitty/ 2>/dev/null || true
    cp "$config_src"/current-theme.conf ~/.config/kitty/ 2>/dev/null || true
    log_success "Kitty configuration applied"
}
