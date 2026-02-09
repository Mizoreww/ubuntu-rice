#!/bin/bash
# ============================================
# 系统美化配置备份脚本
# 作者: limx
# 日期: 2026-02-03
# ============================================

set -e

BACKUP_DIR=~/beautify-configs
DATE=$(date +%Y%m%d_%H%M%S)

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════╗"
echo "║     系统美化配置备份脚本               ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}正在备份美化配置到 $BACKUP_DIR ...${NC}"
echo ""

mkdir -p "$BACKUP_DIR"

# 备份 Kitty 配置
if [ -d ~/.config/kitty ]; then
    cp ~/.config/kitty/kitty.conf "$BACKUP_DIR/" 2>/dev/null || true
    cp ~/.config/kitty/current-theme.conf "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ Kitty 配置已备份${NC}"
fi

# 备份 Zsh 配置
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc "$BACKUP_DIR/zshrc"
    echo -e "${GREEN}✓ .zshrc 已备份${NC}"
fi

if [ -f ~/.p10k.zsh ]; then
    cp ~/.p10k.zsh "$BACKUP_DIR/p10k.zsh"
    echo -e "${GREEN}✓ .p10k.zsh 已备份${NC}"
fi

# 备份 Fcitx5 配置
if [ -d ~/.config/fcitx5 ]; then
    cp ~/.config/fcitx5/conf/classicui.conf "$BACKUP_DIR/" 2>/dev/null || true
    cp ~/.config/fcitx5/conf/pinyin.conf "$BACKUP_DIR/" 2>/dev/null || true
    cp ~/.config/fcitx5/profile "$BACKUP_DIR/fcitx5-profile" 2>/dev/null || true
    echo -e "${GREEN}✓ Fcitx5 配置已备份${NC}"
fi

# 备份 Kitty 桌面启动器
if [ -f ~/.local/share/applications/kitty.desktop ]; then
    cp ~/.local/share/applications/kitty.desktop "$BACKUP_DIR/"
    echo -e "${GREEN}✓ Kitty 桌面启动器已备份${NC}"
fi

# 备份 GNOME 扩展设置
if command -v dconf &> /dev/null; then
    dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions.dconf"
    dconf dump /org/gnome/desktop/interface/ > "$BACKUP_DIR/gnome-interface.dconf"
    dconf dump /org/gnome/desktop/wm/preferences/ > "$BACKUP_DIR/gnome-wm.dconf"
    echo -e "${GREEN}✓ GNOME 设置已备份${NC}"
fi

# 创建已安装软件清单
echo -e "${BLUE}生成软件清单...${NC}"
cat > "$BACKUP_DIR/packages.txt" << 'EOF'
# APT 包
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

# 手动安装
# Kitty (官方安装脚本): curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# Oh-My-Zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Powerlevel10k: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
# zsh-autosuggestions: git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# zsh-syntax-highlighting: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# MesloLGS NF: https://github.com/romkatv/powerlevel10k-media
# Orchis 主题: https://github.com/vinceliuice/Orchis-theme
# Tela 图标: https://github.com/vinceliuice/Tela-icon-theme
# Bibata 光标: https://github.com/ful1e5/Bibata_Cursor

# GNOME 扩展
# Blur my Shell: https://extensions.gnome.org/extension/3193/blur-my-shell/
# Dash to Dock: https://extensions.gnome.org/extension/307/dash-to-dock/
# Just Perfection: https://extensions.gnome.org/extension/3843/just-perfection/
# User Themes: https://extensions.gnome.org/extension/19/user-themes/
EOF
echo -e "${GREEN}✓ 软件清单已生成${NC}"

# 创建压缩包
cd ~
tar -czf "beautify-backup-$DATE.tar.gz" beautify-configs/

echo ""
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║          备份完成!                     ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}备份文件:${NC} ~/beautify-backup-$DATE.tar.gz"
echo -e "${GREEN}配置目录:${NC} $BACKUP_DIR"
echo ""
echo -e "${BLUE}备份内容:${NC}"
ls -la "$BACKUP_DIR"
