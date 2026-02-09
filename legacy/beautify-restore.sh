#!/bin/bash
# ============================================
# 系统美化配置恢复脚本
# 作者: limx
# 日期: 2026-02-03
# ============================================

set -e

BACKUP_DIR=~/beautify-configs

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════╗"
echo "║     系统美化配置恢复脚本               ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}错误: 备份目录不存在: $BACKUP_DIR${NC}"
    echo ""
    echo "请先运行备份脚本或解压备份文件:"
    echo "  tar -xzf beautify-backup-XXXXXX.tar.gz -C ~/"
    exit 1
fi

echo -e "${BLUE}正在从 $BACKUP_DIR 恢复配置...${NC}"
echo ""

# 恢复 Kitty 配置
if [ -f "$BACKUP_DIR/kitty.conf" ]; then
    mkdir -p ~/.config/kitty
    cp "$BACKUP_DIR/kitty.conf" ~/.config/kitty/
    cp "$BACKUP_DIR/current-theme.conf" ~/.config/kitty/ 2>/dev/null || true
    echo -e "${GREEN}✓ Kitty 配置已恢复${NC}"
fi

# 恢复 Zsh 配置
if [ -f "$BACKUP_DIR/zshrc" ]; then
    # 备份现有配置
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.bak
    fi
    cp "$BACKUP_DIR/zshrc" ~/.zshrc
    echo -e "${GREEN}✓ .zshrc 已恢复${NC}"
fi

if [ -f "$BACKUP_DIR/p10k.zsh" ]; then
    cp "$BACKUP_DIR/p10k.zsh" ~/.p10k.zsh
    echo -e "${GREEN}✓ .p10k.zsh 已恢复${NC}"
fi

# 恢复 Fcitx5 配置
if [ -f "$BACKUP_DIR/classicui.conf" ]; then
    mkdir -p ~/.config/fcitx5/conf
    cp "$BACKUP_DIR/classicui.conf" ~/.config/fcitx5/conf/
    cp "$BACKUP_DIR/pinyin.conf" ~/.config/fcitx5/conf/ 2>/dev/null || true
    cp "$BACKUP_DIR/fcitx5-profile" ~/.config/fcitx5/profile 2>/dev/null || true
    echo -e "${GREEN}✓ Fcitx5 配置已恢复${NC}"
fi

# 恢复 Kitty 桌面启动器
if [ -f "$BACKUP_DIR/kitty.desktop" ]; then
    mkdir -p ~/.local/share/applications
    cp "$BACKUP_DIR/kitty.desktop" ~/.local/share/applications/
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
    echo -e "${GREEN}✓ Kitty 桌面启动器已恢复${NC}"
fi

# 恢复 GNOME 设置
if [ -f "$BACKUP_DIR/gnome-extensions.dconf" ]; then
    read -p "是否恢复 GNOME 扩展设置? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions.dconf"
        echo -e "${GREEN}✓ GNOME 扩展设置已恢复${NC}"
    fi
fi

if [ -f "$BACKUP_DIR/gnome-interface.dconf" ]; then
    read -p "是否恢复 GNOME 界面设置? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/gnome-interface.dconf"
        echo -e "${GREEN}✓ GNOME 界面设置已恢复${NC}"
    fi
fi

if [ -f "$BACKUP_DIR/gnome-wm.dconf" ]; then
    read -p "是否恢复 GNOME 窗口管理设置? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dconf load /org/gnome/desktop/wm/preferences/ < "$BACKUP_DIR/gnome-wm.dconf"
        echo -e "${GREEN}✓ GNOME 窗口管理设置已恢复${NC}"
    fi
fi

# 重启 Fcitx5
if command -v fcitx5 &> /dev/null; then
    fcitx5 -r -d 2>/dev/null &
    echo -e "${GREEN}✓ Fcitx5 已重启${NC}"
fi

echo ""
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║          恢复完成!                     ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}后续步骤:${NC}"
echo "  1. 重启终端或运行 'exec zsh'"
echo "  2. 注销并重新登录以应用 GNOME 设置"
echo ""
