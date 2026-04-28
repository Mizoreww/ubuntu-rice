#!/bin/bash
# Ubuntu Rice - Configuration Backup Script
set -e

# ── Resolve project directory ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DIR="$SCRIPT_DIR"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/tui.sh"

BACKUP_DIR=~/ubuntu-rice-configs
DATE=$(date +%Y%m%d_%H%M%S)

print_banner "ubuntu-rice backup"

# ── Build checklist of available configs ─────────────────────────────────
checklist_items=()

if [ -d ~/.config/ghostty ]; then
    checklist_items+=("ghostty" "Ghostty terminal configuration" "ON")
fi

if [ -f ~/.zshrc ]; then
    checklist_items+=("zsh" "Zsh / Oh-My-Zsh / Powerlevel10k" "ON")
fi

if [ -d ~/.config/fcitx5 ]; then
    checklist_items+=("fcitx5" "Fcitx5 input method configuration" "ON")
fi

if command -v dconf &>/dev/null; then
    checklist_items+=("gnome" "GNOME shell & desktop settings" "ON")
fi

if [ ${#checklist_items[@]} -eq 0 ]; then
    log_warn "No configurations found to back up."
    exit 0
fi

# ── TUI selection ───────────────────────────────────────────────────────
selected="$(tui_checklist "Select configs to back up" "${checklist_items[@]}")" || {
    log_info "Cancelled by user."
    exit 0
}

if [[ -z "$selected" ]]; then
    log_info "No components selected."
    exit 0
fi

mkdir -p "$BACKUP_DIR"

# ── Backup selected components ──────────────────────────────────────────

for component in $selected; do
    case "$component" in
        ghostty)
            mkdir -p "$BACKUP_DIR/ghostty"
            cp ~/.config/ghostty/config "$BACKUP_DIR/ghostty/" 2>/dev/null || true
            log_success "Ghostty config backed up"
            ;;
        zsh)
            if [ -f ~/.zshrc ]; then
                cp ~/.zshrc "$BACKUP_DIR/zshrc"
                log_success ".zshrc backed up"
            fi
            if [ -f ~/.p10k.zsh ]; then
                cp ~/.p10k.zsh "$BACKUP_DIR/p10k.zsh"
                log_success ".p10k.zsh backed up"
            fi
            ;;
        fcitx5)
            cp ~/.config/fcitx5/conf/classicui.conf "$BACKUP_DIR/" 2>/dev/null || true
            cp ~/.config/fcitx5/conf/pinyin.conf "$BACKUP_DIR/" 2>/dev/null || true
            cp ~/.config/fcitx5/profile "$BACKUP_DIR/fcitx5-profile" 2>/dev/null || true
            log_success "Fcitx5 config backed up"
            ;;
        gnome)
            dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions.dconf"
            dconf dump /org/gnome/desktop/interface/ > "$BACKUP_DIR/gnome-interface.dconf"
            dconf dump /org/gnome/desktop/wm/preferences/ > "$BACKUP_DIR/gnome-wm.dconf"
            log_success "GNOME settings backed up"
            ;;
    esac
done

# ── Generate package manifest ───────────────────────────────────────────
log_info "Generating package manifest..."
cat > "$BACKUP_DIR/packages.txt" << 'EOF'
# APT packages
git
curl
wget
zsh
fontconfig
gnome-tweaks
gnome-shell-extension-manager
dconf-cli
fcitx5
fcitx5-chinese-addons
fcitx5-material-color
fcitx5-config-qt

# Manually installed
# Ghostty: sudo add-apt-repository ppa:mkasberg/ghostty && sudo apt install ghostty
# Oh-My-Zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Powerlevel10k: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
# zsh-autosuggestions: git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# zsh-syntax-highlighting: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# MesloLGS NF: https://github.com/romkatv/powerlevel10k-media
# Orchis theme: https://github.com/vinceliuice/Orchis-theme
# Tela icons: https://github.com/vinceliuice/Tela-icon-theme
# Bibata cursor: https://github.com/ful1e5/Bibata_Cursor

# GNOME Extensions
# Blur my Shell: https://extensions.gnome.org/extension/3193/blur-my-shell/
# Dash to Dock: https://extensions.gnome.org/extension/307/dash-to-dock/
# Just Perfection: https://extensions.gnome.org/extension/3843/just-perfection/
# User Themes: https://extensions.gnome.org/extension/19/user-themes/
EOF
log_success "Package manifest saved"

# ── Create archive ──────────────────────────────────────────────────────
tar -czf ~/ubuntu-rice-backup-$DATE.tar.gz -C ~ ubuntu-rice-configs/

print_banner "Backup Complete"
log_success "Archive: ~/ubuntu-rice-backup-$DATE.tar.gz"
log_info  "Config dir: $BACKUP_DIR"
