# 系统美化配置备份与一键安装脚本

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 总结系统所有美化配置并生成一键安装脚本

**Architecture:** 收集所有美化配置 → 生成配置备份 → 创建一键安装脚本

**Tech Stack:** Bash, GNOME, Zsh, Oh-My-Zsh, Powerlevel10k, Kitty, Fcitx5

---

## 系统美化配置完整总结

### 1. 终端美化 (Kitty + Tokyo Night Moon)

| 配置项 | 值 |
|--------|-----|
| 终端模拟器 | Kitty v0.45.0 |
| 主题 | Tokyo Night Moon |
| 字体 | MesloLGS NF 14pt |
| 透明度 | 90% |
| 标签栏样式 | Powerline (斜切) |
| 光标样式 | Beam, 闪烁 0.5s |

**配置文件:**
- `/home/limx/.config/kitty/kitty.conf`
- `/home/limx/.config/kitty/current-theme.conf`

### 2. Shell 美化 (Zsh + Oh-My-Zsh + Powerlevel10k)

| 配置项 | 值 |
|--------|-----|
| Shell | Zsh |
| 框架 | Oh-My-Zsh |
| 主题 | Powerlevel10k (Rainbow) |
| 图标模式 | NerdFont v3 |
| 提示符 | 双行, 过渡式 |

**插件列表:**
1. `git` - Git 集成
2. `zsh-autosuggestions` - 自动建议
3. `zsh-syntax-highlighting` - 语法高亮

**配置文件:**
- `/home/limx/.zshrc`
- `/home/limx/.p10k.zsh`
- `/home/limx/.oh-my-zsh/custom/themes/powerlevel10k/`
- `/home/limx/.oh-my-zsh/custom/plugins/zsh-autosuggestions/`
- `/home/limx/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/`

### 3. 桌面环境美化 (GNOME)

| 配置项 | 值 |
|--------|-----|
| 桌面环境 | GNOME Shell 46.0 |
| Shell 主题 | Yaru-blue-dark |
| GTK 主题 | Yaru |
| 图标主题 | Tela-blue |
| 光标主题 | Bibata-Modern-Ice |
| 光标大小 | 48px |
| 文本缩放 | 125% |

**GNOME 扩展 (6 个):**
1. `blur-my-shell@aunetx` - 模糊效果
2. `dash-to-dock@micxgx.gmail.com` - Dock 栏
3. `just-perfection-desktop@just-perfection` - 界面微调
4. `user-theme@gnome-shell-extensions.gcampax.github.com` - 用户主题
5. `ding@rastersoft.com` - 桌面图标
6. `tiling-assistant@ubuntu.com` - 平铺助手

**Dock 配置:**
- 位置: 底部
- 图标大小: 77px
- 自动隐藏: 启用
- 透明度: 80%

**主题文件:**
- `~/.themes/Orchis*` - Orchis 主题系列
- `~/.themes/Flat-Remix-Light`
- `~/.icons/Tela-blue*` - Tela 图标
- `~/.icons/Bibata-Modern-Ice` - 光标

### 4. 输入法美化 (Fcitx5)

| 配置项 | 值 |
|--------|-----|
| 输入法框架 | Fcitx5 5.1.7 |
| 主题 | Material-Color-deepPurple |
| 字体 | Noto Sans CJK SC 12pt |
| 输入方案 | 自然码双拼 |
| 候选词数 | 7 个/页 |

**配置文件:**
- `/home/limx/.config/fcitx5/conf/classicui.conf`
- `/home/limx/.config/fcitx5/conf/pinyin.conf`
- `/home/limx/.config/fcitx5/profile`

### 5. 字体配置

**已安装美化字体:**
| 字体 | 用途 |
|------|------|
| MesloLGS NF | 终端 (Nerd Font) |
| Fira Code | 编程 (连字支持) |
| Noto Sans CJK SC | 中文显示 |
| Noto Color Emoji | Emoji |
| Ubuntu Sans | 系统界面 |

**字体目录:**
- `~/.local/share/fonts/` - 用户字体
- `/usr/share/fonts/` - 系统字体

---

## 一键安装脚本

### Task 1: 创建安装脚本主文件

**Files:**
- Create: `~/beautify-install.sh`

**Step 1: 创建脚本**

```bash
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
# 7. 安装 GNOME 扩展
# ============================================
echo -e "${BLUE}[7/8] 安装 GNOME 扩展...${NC}"

# 需要手动从 extensions.gnome.org 安装的扩展列表
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
    # 应用配置 (需要配置文件存在)
    if [ -f ~/beautify-configs/kitty.conf ]; then
        mkdir -p ~/.config/kitty
        cp ~/beautify-configs/kitty.conf ~/.config/kitty/
        cp ~/beautify-configs/current-theme.conf ~/.config/kitty/
    fi

    if [ -f ~/beautify-configs/zshrc ]; then
        cp ~/beautify-configs/zshrc ~/.zshrc
    fi

    if [ -f ~/beautify-configs/p10k.zsh ]; then
        cp ~/beautify-configs/p10k.zsh ~/.p10k.zsh
    fi

    if [ -f ~/beautify-configs/classicui.conf ]; then
        mkdir -p ~/.config/fcitx5/conf
        cp ~/beautify-configs/classicui.conf ~/.config/fcitx5/conf/
    fi

    echo -e "${GREEN}✓ 配置文件已应用${NC}"
fi

# ============================================
# 应用 GNOME 设置
# ============================================
echo -e "${BLUE}应用 GNOME 设置...${NC}"

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
```

---

### Task 2: 创建配置文件备份脚本

**Files:**
- Create: `~/beautify-backup.sh`

**Step 1: 创建备份脚本**

```bash
#!/bin/bash
# ============================================
# 系统美化配置备份脚本
# ============================================

BACKUP_DIR=~/beautify-configs
DATE=$(date +%Y%m%d_%H%M%S)

echo "正在备份美化配置到 $BACKUP_DIR ..."

mkdir -p "$BACKUP_DIR"

# 备份 Kitty 配置
if [ -d ~/.config/kitty ]; then
    cp ~/.config/kitty/kitty.conf "$BACKUP_DIR/" 2>/dev/null
    cp ~/.config/kitty/current-theme.conf "$BACKUP_DIR/" 2>/dev/null
    echo "✓ Kitty 配置已备份"
fi

# 备份 Zsh 配置
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc "$BACKUP_DIR/zshrc"
    echo "✓ .zshrc 已备份"
fi

if [ -f ~/.p10k.zsh ]; then
    cp ~/.p10k.zsh "$BACKUP_DIR/p10k.zsh"
    echo "✓ .p10k.zsh 已备份"
fi

# 备份 Fcitx5 配置
if [ -d ~/.config/fcitx5 ]; then
    cp ~/.config/fcitx5/conf/classicui.conf "$BACKUP_DIR/" 2>/dev/null
    cp ~/.config/fcitx5/conf/pinyin.conf "$BACKUP_DIR/" 2>/dev/null
    cp ~/.config/fcitx5/profile "$BACKUP_DIR/fcitx5-profile" 2>/dev/null
    echo "✓ Fcitx5 配置已备份"
fi

# 备份 Kitty 桌面启动器
if [ -f ~/.local/share/applications/kitty.desktop ]; then
    cp ~/.local/share/applications/kitty.desktop "$BACKUP_DIR/"
    echo "✓ Kitty 桌面启动器已备份"
fi

# 备份 GNOME 扩展设置
if command -v dconf &> /dev/null; then
    dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions.dconf"
    dconf dump /org/gnome/desktop/interface/ > "$BACKUP_DIR/gnome-interface.dconf"
    echo "✓ GNOME 设置已备份"
fi

# 创建压缩包
cd ~
tar -czf "beautify-backup-$DATE.tar.gz" beautify-configs/
echo ""
echo "备份完成: ~/beautify-backup-$DATE.tar.gz"
echo "配置目录: $BACKUP_DIR"
```

---

### Task 3: 创建配置恢复脚本

**Files:**
- Create: `~/beautify-restore.sh`

**Step 1: 创建恢复脚本**

```bash
#!/bin/bash
# ============================================
# 系统美化配置恢复脚本
# ============================================

BACKUP_DIR=~/beautify-configs

if [ ! -d "$BACKUP_DIR" ]; then
    echo "错误: 备份目录不存在: $BACKUP_DIR"
    exit 1
fi

echo "正在从 $BACKUP_DIR 恢复配置..."

# 恢复 Kitty 配置
if [ -f "$BACKUP_DIR/kitty.conf" ]; then
    mkdir -p ~/.config/kitty
    cp "$BACKUP_DIR/kitty.conf" ~/.config/kitty/
    cp "$BACKUP_DIR/current-theme.conf" ~/.config/kitty/ 2>/dev/null
    echo "✓ Kitty 配置已恢复"
fi

# 恢复 Zsh 配置
if [ -f "$BACKUP_DIR/zshrc" ]; then
    cp "$BACKUP_DIR/zshrc" ~/.zshrc
    echo "✓ .zshrc 已恢复"
fi

if [ -f "$BACKUP_DIR/p10k.zsh" ]; then
    cp "$BACKUP_DIR/p10k.zsh" ~/.p10k.zsh
    echo "✓ .p10k.zsh 已恢复"
fi

# 恢复 Fcitx5 配置
if [ -f "$BACKUP_DIR/classicui.conf" ]; then
    mkdir -p ~/.config/fcitx5/conf
    cp "$BACKUP_DIR/classicui.conf" ~/.config/fcitx5/conf/
    cp "$BACKUP_DIR/pinyin.conf" ~/.config/fcitx5/conf/ 2>/dev/null
    cp "$BACKUP_DIR/fcitx5-profile" ~/.config/fcitx5/profile 2>/dev/null
    echo "✓ Fcitx5 配置已恢复"
fi

# 恢复 Kitty 桌面启动器
if [ -f "$BACKUP_DIR/kitty.desktop" ]; then
    mkdir -p ~/.local/share/applications
    cp "$BACKUP_DIR/kitty.desktop" ~/.local/share/applications/
    update-desktop-database ~/.local/share/applications/ 2>/dev/null
    echo "✓ Kitty 桌面启动器已恢复"
fi

# 恢复 GNOME 设置
if [ -f "$BACKUP_DIR/gnome-extensions.dconf" ]; then
    dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions.dconf"
    echo "✓ GNOME 扩展设置已恢复"
fi

if [ -f "$BACKUP_DIR/gnome-interface.dconf" ]; then
    dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/gnome-interface.dconf"
    echo "✓ GNOME 界面设置已恢复"
fi

echo ""
echo "恢复完成! 请重启终端和注销重新登录以应用所有更改。"
```

---

## 配置文件清单

| 文件 | 路径 | 说明 |
|------|------|------|
| kitty.conf | ~/.config/kitty/ | Kitty 主配置 |
| current-theme.conf | ~/.config/kitty/ | Tokyo Night Moon 主题 |
| .zshrc | ~/ | Zsh 配置 |
| .p10k.zsh | ~/ | Powerlevel10k 配置 |
| classicui.conf | ~/.config/fcitx5/conf/ | Fcitx5 UI 主题 |
| pinyin.conf | ~/.config/fcitx5/conf/ | 拼音输入法配置 |
| kitty.desktop | ~/.local/share/applications/ | Kitty 启动器 |

## 软件包清单

```bash
# APT 包
git curl wget zsh fontconfig gnome-tweaks gnome-shell-extension-manager dconf-cli
fcitx5 fcitx5-chinese-addons fcitx5-material-color fcitx5-config-qt

# 手动安装
- Kitty (官方安装脚本)
- Oh-My-Zsh
- Powerlevel10k 主题
- zsh-autosuggestions 插件
- zsh-syntax-highlighting 插件
- MesloLGS NF 字体
- Orchis GTK 主题
- Tela 图标主题
- Bibata 光标主题

# GNOME 扩展
- Blur my Shell
- Dash to Dock
- Just Perfection
- User Themes
```
