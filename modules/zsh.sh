# zsh.sh - Zsh + Oh-My-Zsh module
# Zsh with Oh-My-Zsh, Powerlevel10k theme, and useful plugins

zsh_name="Zsh + Oh-My-Zsh"
zsh_desc="Zsh with Oh-My-Zsh, Powerlevel10k, and plugins"

# Check if Oh-My-Zsh is installed
zsh_check() {
    test -d ~/.oh-my-zsh
}

# Zsh supports all Ubuntu versions
zsh_supported() {
    return 0
}

# Install Zsh, Oh-My-Zsh, Powerlevel10k, and plugins
zsh_install() {
    local ver="$1"

    log_info "Installing Zsh..."
    pkg_install zsh

    # Install Oh-My-Zsh (unattended mode)
    if [ ! -d ~/.oh-my-zsh ]; then
        log_info "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh-My-Zsh installed"
    else
        log_warn "Oh-My-Zsh is already installed"
    fi

    # Install Powerlevel10k theme
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        log_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            ~/.oh-my-zsh/custom/themes/powerlevel10k
        log_success "Powerlevel10k installed"
    else
        log_warn "Powerlevel10k is already installed"
    fi

    # Install zsh-autosuggestions plugin
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        log_success "zsh-autosuggestions installed"
    else
        log_warn "zsh-autosuggestions is already installed"
    fi

    # Install zsh-syntax-highlighting plugin
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        log_success "zsh-syntax-highlighting installed"
    else
        log_warn "zsh-syntax-highlighting is already installed"
    fi

    # Set Zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
        log_success "Default shell set to Zsh"
    fi
}

# Uninstall Oh-My-Zsh and restore Bash as default shell
zsh_uninstall() {
    log_info "Restoring Bash as default shell..."
    chsh -s "$(which bash)"

    log_info "Removing Oh-My-Zsh..."
    rm -rf ~/.oh-my-zsh

    # Don't delete .zshrc - user might want to keep it
    log_success "Oh-My-Zsh uninstalled (kept ~/.zshrc)"
}

# Apply Zsh configuration files (.zshrc and .p10k.zsh)
zsh_apply_config() {
    local config_src="$1"

    if [ -f "$config_src/zshrc" ]; then
        log_info "Applying .zshrc..."
        # Backup existing .zshrc before overwriting
        [ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak
        cp "$config_src/zshrc" ~/.zshrc
        log_success ".zshrc applied (backup saved as .zshrc.bak)"
    fi

    if [ -f "$config_src/p10k.zsh" ]; then
        log_info "Applying .p10k.zsh..."
        cp "$config_src/p10k.zsh" ~/.p10k.zsh
        log_success ".p10k.zsh applied"
    fi
}
