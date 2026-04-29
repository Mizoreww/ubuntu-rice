#!/bin/bash
# locale.sh - System locale module
# Switch system language to Simplified Chinese (zh_CN.UTF-8) while
# keeping XDG user directories (Desktop, Downloads, ...) in English.

locale_name="System Locale (zh_CN, English XDG dirs)"
locale_desc="中文系统界面 + 保持英文 ~/Desktop, ~/Downloads 等目录"

# A locale module is supported on every Ubuntu version we target.
locale_supported() {
    return 0
}

# Consider it "installed" if the running shell already uses zh_CN
# AND the user-dirs locale is pinned to en_US (so the rename prompt
# will not reappear on next login).
locale_check() {
    local sys_lang user_lang
    sys_lang="$(grep -E '^LANG=' /etc/default/locale 2>/dev/null | cut -d= -f2 | tr -d '"')"
    user_lang="$(cat "${HOME}/.config/user-dirs.locale" 2>/dev/null || echo '')"

    [[ "$sys_lang" == "zh_CN.UTF-8" ]] && [[ "$user_lang" == "en_US" ]]
}

locale_install() {
    log_info "Installing Simplified Chinese language packs..."
    pkg_install language-pack-zh-hans language-pack-gnome-zh-hans \
                fonts-noto-cjk fonts-noto-cjk-extra || true

    log_info "Generating zh_CN.UTF-8 locale..."
    sudo locale-gen zh_CN.UTF-8 en_US.UTF-8

    log_info "Setting system LANG to zh_CN.UTF-8 (LANGUAGE keeps en fallback)..."
    sudo update-locale LANG=zh_CN.UTF-8 LANGUAGE="zh_CN:zh:en_US:en"

    # Pin XDG user dirs to English BEFORE the next login so GNOME does not
    # offer to rename ~/Desktop → ~/桌面 etc.
    log_info "Pinning XDG user directories to English..."
    mkdir -p "${HOME}/.config"
    echo "en_US" > "${HOME}/.config/user-dirs.locale"

    # Also force-regenerate user-dirs.dirs in English in case the file is
    # missing or already partially translated.
    if command -v xdg-user-dirs-update &>/dev/null; then
        LC_ALL=C LANG=en_US.UTF-8 xdg-user-dirs-update --force 2>/dev/null || true
    fi

    log_success "System locale set to zh_CN.UTF-8; XDG dirs pinned to English"
    log_warn "Log out and log back in for the language change to take effect"
}

locale_uninstall() {
    log_info "Reverting system locale to en_US.UTF-8..."
    sudo update-locale LANG=en_US.UTF-8 LANGUAGE="en_US:en"
    rm -f "${HOME}/.config/user-dirs.locale"
    log_success "System locale reverted to en_US.UTF-8"
}

# Nothing dconf-shaped to apply for the locale module.
locale_apply_config() {
    return 0
}
