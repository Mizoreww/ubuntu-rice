#!/bin/bash
# Ubuntu Rice - Configuration Restore Script
set -e

# ── Resolve project directory ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DIR="$SCRIPT_DIR"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/tui.sh"

BACKUP_DIR=~/ubuntu-rice-configs

# ── Extract archive if provided as argument ─────────────────────────────
if [ -n "$1" ] && [ -f "$1" ]; then
    log_info "Extracting backup from $1..."
    tar -xzf "$1" -C ~/
fi

if [ ! -d "$BACKUP_DIR" ]; then
    log_error "Backup directory not found: $BACKUP_DIR"
    echo "Usage: ./restore.sh [backup.tar.gz]"
    exit 1
fi

print_banner "ubuntu-rice restore"

# ── Build checklist of available backups ─────────────────────────────────
checklist_items=()

if [ -f "$BACKUP_DIR/kitty.conf" ]; then
    checklist_items+=("kitty" "Kitty terminal configuration" "ON")
fi

if [ -f "$BACKUP_DIR/zshrc" ]; then
    checklist_items+=("zsh" "Zsh / Oh-My-Zsh / Powerlevel10k" "ON")
fi

if [ -f "$BACKUP_DIR/classicui.conf" ]; then
    checklist_items+=("fcitx5" "Fcitx5 input method configuration" "ON")
fi

if [ -f "$BACKUP_DIR/gnome-extensions.dconf" ] || [ -f "$BACKUP_DIR/gnome-interface.dconf" ]; then
    checklist_items+=("gnome" "GNOME shell & desktop settings" "ON")
fi

if [ ${#checklist_items[@]} -eq 0 ]; then
    log_warn "No backed-up configurations found in $BACKUP_DIR."
    exit 0
fi

# ── TUI selection ───────────────────────────────────────────────────────
selected="$(tui_checklist "Select configs to restore" "${checklist_items[@]}")" || {
    log_info "Cancelled by user."
    exit 0
}

if [[ -z "$selected" ]]; then
    log_info "No components selected."
    exit 0
fi

# ── Restore selected components ─────────────────────────────────────────

for component in $selected; do
    case "$component" in
        kitty)
            mkdir -p ~/.config/kitty
            cp "$BACKUP_DIR/kitty.conf" ~/.config/kitty/
            cp "$BACKUP_DIR/current-theme.conf" ~/.config/kitty/ 2>/dev/null || true
            log_success "Kitty config restored"
            ;;
        zsh)
            if [ -f "$BACKUP_DIR/zshrc" ]; then
                # Back up existing config before overwriting
                if [ -f ~/.zshrc ]; then
                    cp ~/.zshrc ~/.zshrc.bak
                    log_info "Existing .zshrc saved as .zshrc.bak"
                fi
                cp "$BACKUP_DIR/zshrc" ~/.zshrc
                log_success ".zshrc restored"
            fi
            if [ -f "$BACKUP_DIR/p10k.zsh" ]; then
                cp "$BACKUP_DIR/p10k.zsh" ~/.p10k.zsh
                log_success ".p10k.zsh restored"
            fi
            ;;
        fcitx5)
            mkdir -p ~/.config/fcitx5/conf
            cp "$BACKUP_DIR/classicui.conf" ~/.config/fcitx5/conf/
            cp "$BACKUP_DIR/pinyin.conf" ~/.config/fcitx5/conf/ 2>/dev/null || true
            cp "$BACKUP_DIR/fcitx5-profile" ~/.config/fcitx5/profile 2>/dev/null || true
            log_success "Fcitx5 config restored"
            ;;
        gnome)
            if ! tui_yesno "Restore GNOME" "Restore GNOME desktop settings?\nThis will overwrite current appearance settings."; then
                log_info "Skipping GNOME settings restore"
                continue
            fi
            if [ -f "$BACKUP_DIR/gnome-extensions.dconf" ]; then
                dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions.dconf"
            fi
            if [ -f "$BACKUP_DIR/gnome-interface.dconf" ]; then
                dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/gnome-interface.dconf"
            fi
            if [ -f "$BACKUP_DIR/gnome-wm.dconf" ]; then
                dconf load /org/gnome/desktop/wm/preferences/ < "$BACKUP_DIR/gnome-wm.dconf"
            fi
            log_success "GNOME settings restored"
            ;;
    esac
done

# ── Restart Fcitx5 if it was restored ───────────────────────────────────
if [[ " $selected " == *" fcitx5 "* ]] && command -v fcitx5 &>/dev/null; then
    fcitx5 -r -d 2>/dev/null &
    log_success "Fcitx5 restarted"
fi

# ── Done ────────────────────────────────────────────────────────────────
print_banner "Restore Complete"
log_info "You may need to:"
log_info "  - Restart your terminal or run 'exec zsh'"
log_info "  - Log out and log back in for GNOME changes"
