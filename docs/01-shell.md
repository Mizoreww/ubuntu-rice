# 01 — 终端环境（Ghostty + Zsh + 字体）

GUI 桌面之外，先把终端栈打通：Ghostty 替掉 gnome-terminal、Zsh 替掉 bash、装上 powerlevel10k 需要的 Nerd Font。

## Ghostty

GPU 加速终端，作为系统默认 `x-terminal-emulator`。

### 安装

```bash
# 准备 add-apt-repository
sudo apt-get update -qq
sudo apt-get install -y software-properties-common

# 社区维护的 PPA（22.04 / 24.04 都有 build；20.04 没有）
sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
sudo apt-get update -qq

# ghostty 主包 + 必备伴生
#   python3-nautilus  → 启用右键"Open in Ghostty"
#   xclip / wl-clipboard → TUI 工具（Claude Code 等）才能访问系统剪贴板
sudo apt-get install -y ghostty python3-nautilus xclip wl-clipboard

# 移除 gnome-terminal 的 nautilus 扩展，否则右键有两个"Open in Terminal"
sudo apt-get remove -y nautilus-extension-gnome-terminal || true
```

### 设为默认终端

```bash
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
    x-terminal-emulator "$(command -v ghostty)" 60
sudo update-alternatives --set x-terminal-emulator "$(command -v ghostty)"

# GNOME 42+ 用这两个 gsetting；老版本会忽略
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
```

### 配置

```bash
mkdir -p ~/.config/ghostty
cp configs/default/ghostty/config ~/.config/ghostty/config
```

### 已知坑

- **PPA 全名是 `ppa:mkasberg/ghostty-ubuntu`**，不是 `mkasberg/ghostty`。
- **Ghostty 1.3.1+ 用 `shell-integration-features = no-cursor`** 禁用光标自动切换；老语法 `-cursor` 已废弃。`configs/default/ghostty/config` 里已经是 `no-cursor`。
- 不装 `python3-nautilus`，"Open in Ghostty" 右键不会出现。
- 不装 `xclip` / `wl-clipboard`，Claude Code 这类 Node/Electron CLI 静默丢失复制粘贴。
- Ubuntu 20.04 PPA 没 build —— 该版本只能源码编译，本仓库不支持。

### Verify

```bash
command -v ghostty &>/dev/null && \
  grep -q 'no-cursor' ~/.config/ghostty/config && \
  ! dpkg -l nautilus-extension-gnome-terminal &>/dev/null && \
  echo OK
```

## Zsh + Oh-My-Zsh + Powerlevel10k

### 安装

```bash
sudo apt-get install -y zsh

# Oh-My-Zsh（unattended）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Powerlevel10k 主题
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ~/.oh-my-zsh/custom/themes/powerlevel10k

# 插件
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 默认 shell
chsh -s "$(command -v zsh)"
```

### 配置

```bash
# 备份现有 .zshrc，然后用项目自带的覆盖
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak
cp configs/default/zsh/zshrc   ~/.zshrc
cp configs/default/zsh/p10k.zsh ~/.p10k.zsh
```

### 已知坑

- `chsh -s` 修改的是 `/etc/passwd`，**下次登录才生效**。当前 session 想立刻进 zsh 直接 `exec zsh`。
- Oh-My-Zsh 安装脚本会**覆盖 `~/.zshrc`**；自定义内容务必先备份（上面的 `cp .zshrc .zshrc.bak` 已处理）。
- vi-mode 插件会用 DECSCUSR 转义改光标形状 —— 已知和 Ghostty 的 `no-cursor` 冲突；保持默认 plugin 集合即可，不要主动加 `vi-mode`。

### Verify

```bash
test -d ~/.oh-my-zsh && \
  test -d ~/.oh-my-zsh/custom/themes/powerlevel10k && \
  test -f ~/.zshrc && \
  echo OK
```

## Nerd Fonts (MesloLGS NF)

Powerlevel10k 默认风格需要的图标字体。

### 安装

```bash
mkdir -p ~/.local/share/fonts
base="https://github.com/romkatv/powerlevel10k-media/raw/master"
for style in "Regular" "Bold" "Italic" "Bold%20Italic"; do
  wget -q -P ~/.local/share/fonts/ "$base/MesloLGS%20NF%20${style}.ttf"
done
fc-cache -fv
```

### 已知坑

- 文件名包含空格，URL 里要 `%20` 转义。
- `fc-cache -fv` 不跑的话 GTK / Ghostty 看不到新字体。

### Verify

```bash
test -f "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf" && \
  fc-list | grep -q 'MesloLGS NF' && echo OK
```
