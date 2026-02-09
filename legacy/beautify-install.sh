#!/bin/bash
# ============================================
# 系统美化一键安装脚本
# 适用于: Ubuntu 24.04 + GNOME
# 作者: limx
# 日期: 2026-02-03
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════╗"
echo "║     系统美化一键安装脚本 v1.0          ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================
# 1. 基础依赖安装
# ============================================
echo -e "${BLUE}[1/8] 安装基础依赖...${NC}"

sudo apt update
sudo apt install -y \
    git \
    curl \
    wget \
    zsh \
    fontconfig \
    gnome-tweaks \
    gnome-shell-extension-manager \
    dconf-cli

# ============================================
# 2. 安装 Kitty 终端
# ============================================
echo -e "${BLUE}[2/8] 安装 Kitty 终端...${NC}"

if ! command -v kitty &> /dev/null; then
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # 创建符号链接
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
    ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten

    # 创建桌面启动器
    mkdir -p ~/.local/share/applications
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

    # 修改启动器支持输入法
    sed -i 's|^Exec=.*kitty$|Exec=env GLFW_IM_MODULE=ibus /home/'"$USER"'/.local/kitty.app/bin/kitty|' \
        ~/.local/share/applications/kitty.desktop

    update-desktop-database ~/.local/share/applications/
    echo -e "${GREEN}✓ Kitty 安装完成${NC}"
else
    echo -e "${YELLOW}✓ Kitty 已安装${NC}"
fi

# ============================================
# 3. 安装 Nerd Fonts (MesloLGS NF)
# ============================================
echo -e "${BLUE}[3/8] 安装 Nerd Fonts...${NC}"

mkdir -p ~/.local/share/fonts

if [ ! -f ~/.local/share/fonts/MesloLGS\ NF\ Regular.ttf ]; then
    cd /tmp
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mv MesloLGS*.ttf ~/.local/share/fonts/
    fc-cache -fv
    echo -e "${GREEN}✓ MesloLGS NF 字体安装完成${NC}"
else
    echo -e "${YELLOW}✓ MesloLGS NF 字体已安装${NC}"
fi

# ============================================
# 4. 安装 Oh-My-Zsh 和插件
# ============================================
echo -e "${BLUE}[4/8] 安装 Oh-My-Zsh...${NC}"

if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}✓ Oh-My-Zsh 安装完成${NC}"
else
    echo -e "${YELLOW}✓ Oh-My-Zsh 已安装${NC}"
fi

# 安装 Powerlevel10k 主题
if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        ~/.oh-my-zsh/custom/themes/powerlevel10k
    echo -e "${GREEN}✓ Powerlevel10k 主题安装完成${NC}"
else
    echo -e "${YELLOW}✓ Powerlevel10k 已安装${NC}"
fi

# 安装 zsh-autosuggestions
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    echo -e "${GREEN}✓ zsh-autosuggestions 安装完成${NC}"
else
    echo -e "${YELLOW}✓ zsh-autosuggestions 已安装${NC}"
fi

# 安装 zsh-syntax-highlighting
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    echo -e "${GREEN}✓ zsh-syntax-highlighting 安装完成${NC}"
else
    echo -e "${YELLOW}✓ zsh-syntax-highlighting 已安装${NC}"
fi

# ============================================
# 5. 安装 Fcitx5 输入法
# ============================================
echo -e "${BLUE}[5/8] 安装 Fcitx5 输入法...${NC}"

sudo apt install -y \
    fcitx5 \
    fcitx5-chinese-addons \
    fcitx5-material-color \
    fcitx5-config-qt

echo -e "${GREEN}✓ Fcitx5 安装完成${NC}"

# ============================================
# 6. 安装 GNOME 主题和图标
# ============================================
echo -e "${BLUE}[6/8] 安装 GNOME 主题和图标...${NC}"

mkdir -p ~/.themes ~/.icons

# 安装 Orchis 主题
if [ ! -d ~/.themes/Orchis ]; then
    cd /tmp
    git clone https://github.com/vinceliuice/Orchis-theme.git
    cd Orchis-theme
    ./install.sh -d ~/.themes
    cd .. && rm -rf Orchis-theme
    echo -e "${GREEN}✓ Orchis 主题安装完成${NC}"
else
    echo -e "${YELLOW}✓ Orchis 主题已安装${NC}"
fi

# 安装 Tela 图标
if [ ! -d ~/.icons/Tela-blue ]; then
    cd /tmp
    git clone https://github.com/vinceliuice/Tela-icon-theme.git
    cd Tela-icon-theme
    ./install.sh -d ~/.icons blue
    cd .. && rm -rf Tela-icon-theme
    echo -e "${GREEN}✓ Tela 图标安装完成${NC}"
else
    echo -e "${YELLOW}✓ Tela 图标已安装${NC}"
fi

# 安装 Bibata 光标
if [ ! -d ~/.icons/Bibata-Modern-Ice ]; then
    cd /tmp
    wget -q https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
    tar -xf Bibata-Modern-Ice.tar.xz -C ~/.icons/
    rm Bibata-Modern-Ice.tar.xz
    echo -e "${GREEN}✓ Bibata 光标安装完成${NC}"
else
    echo -e "${YELLOW}✓ Bibata 光标已安装${NC}"
fi

# ============================================
# 7. 安装 GNOME 扩展提示
# ============================================
echo -e "${BLUE}[7/8] GNOME 扩展安装提示...${NC}"

echo -e "${YELLOW}请手动安装以下 GNOME 扩展:${NC}"
echo "  1. Blur my Shell - https://extensions.gnome.org/extension/3193/blur-my-shell/"
echo "  2. Dash to Dock - https://extensions.gnome.org/extension/307/dash-to-dock/"
echo "  3. Just Perfection - https://extensions.gnome.org/extension/3843/just-perfection/"
echo "  4. User Themes - https://extensions.gnome.org/extension/19/user-themes/"
echo ""
echo -e "${YELLOW}或使用 Extension Manager 应用安装${NC}"

# ============================================
# 8. 应用配置文件
# ============================================
echo -e "${BLUE}[8/8] 应用配置文件...${NC}"

# 询问是否应用配置
read -p "是否应用预设配置文件? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_DIR=~/beautify-configs

    # 应用 Kitty 配置
    if [ -f "$BACKUP_DIR/kitty.conf" ]; then
        mkdir -p ~/.config/kitty
        cp "$BACKUP_DIR/kitty.conf" ~/.config/kitty/
        cp "$BACKUP_DIR/current-theme.conf" ~/.config/kitty/ 2>/dev/null
        echo -e "${GREEN}✓ Kitty 配置已应用${NC}"
    fi

    # 应用 Zsh 配置
    if [ -f "$BACKUP_DIR/zshrc" ]; then
        cp "$BACKUP_DIR/zshrc" ~/.zshrc
        echo -e "${GREEN}✓ .zshrc 已应用${NC}"
    fi

    if [ -f "$BACKUP_DIR/p10k.zsh" ]; then
        cp "$BACKUP_DIR/p10k.zsh" ~/.p10k.zsh
        echo -e "${GREEN}✓ .p10k.zsh 已应用${NC}"
    fi

    # 应用 Fcitx5 配置
    if [ -f "$BACKUP_DIR/classicui.conf" ]; then
        mkdir -p ~/.config/fcitx5/conf
        cp "$BACKUP_DIR/classicui.conf" ~/.config/fcitx5/conf/
        cp "$BACKUP_DIR/pinyin.conf" ~/.config/fcitx5/conf/ 2>/dev/null
        echo -e "${GREEN}✓ Fcitx5 配置已应用${NC}"
    fi

    # 恢复 GNOME 设置
    if [ -f "$BACKUP_DIR/gnome-extensions.dconf" ]; then
        dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions.dconf"
        echo -e "${GREEN}✓ GNOME 扩展设置已应用${NC}"
    fi

    if [ -f "$BACKUP_DIR/gnome-interface.dconf" ]; then
        dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/gnome-interface.dconf"
        echo -e "${GREEN}✓ GNOME 界面设置已应用${NC}"
    fi
fi

# ============================================
# 应用 GNOME 设置
# ============================================
echo -e "${BLUE}应用 GNOME 基础设置...${NC}"

# 设置图标主题
gsettings set org.gnome.desktop.interface icon-theme 'Tela-blue'

# 设置光标主题
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface cursor-size 48

# 设置文本缩放
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

# 设置字体
gsettings set org.gnome.desktop.interface font-name 'Ubuntu Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Sans Mono 13'

echo -e "${GREEN}✓ GNOME 设置已应用${NC}"

# ============================================
# 设置 Zsh 为默认 Shell
# ============================================
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${BLUE}设置 Zsh 为默认 Shell...${NC}"
    chsh -s $(which zsh)
    echo -e "${GREEN}✓ 默认 Shell 已设置为 Zsh${NC}"
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════╗"
echo "║          安装完成!                     ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}后续步骤:${NC}"
echo "  1. 重启终端或运行 'exec zsh'"
echo "  2. 首次启动 Zsh 时运行 'p10k configure' 配置 Powerlevel10k"
echo "  3. 从 GNOME Extension Manager 安装扩展"
echo "  4. 注销并重新登录以应用所有更改"
echo ""
echo -e "${YELLOW}配置文件位置:${NC}"
echo "  - Kitty: ~/.config/kitty/"
echo "  - Zsh: ~/.zshrc, ~/.p10k.zsh"
echo "  - Fcitx5: ~/.config/fcitx5/"
echo ""
