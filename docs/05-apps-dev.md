# 05 — 开发工具

VS Code, Cursor, GitKraken, Termius, Zotero, Miniconda, Typora。

## VS Code

### 安装

```bash
# 走微软官方仓库
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
  https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt-get update -qq && sudo apt-get install -y code
```

### 已知坑

- 第一次 `apt update` 可能会跳出交互式 whiptail 问"是否启用微软仓库"；非交互式环境提前 `export DEBIAN_FRONTEND=noninteractive`。

### Verify

```bash
command -v code && echo OK
```

## Cursor

AI 代码编辑器（VS Code fork）。

### 安装

下载页：https://cursor.com/download （Linux x64）。可能是 `.AppImage` 或 `.deb`：

```bash
# 如果是 .deb：
sudo apt-get install -y ~/Downloads/cursor*_amd64.deb

# 如果是 .AppImage：
sudo install -m 755 ~/Downloads/cursor-*.AppImage /opt/cursor.AppImage
sudo ln -sf /opt/cursor.AppImage /usr/local/bin/cursor
# 自己写 .desktop 启动器（图标自带；下面给个最小版）
cat | sudo tee /usr/share/applications/cursor.desktop <<'EOF'
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.AppImage --no-sandbox %U
Type=Application
Icon=cursor
Categories=Development;IDE;
Terminal=false
EOF
```

### Verify

```bash
command -v cursor &>/dev/null || test -f /usr/share/applications/cursor.desktop && echo OK
```

## GitKraken

### 安装

下载页：https://www.gitkraken.com/download/linux-deb

```bash
sudo apt-get install -y ~/Downloads/gitkraken-amd64.deb
```

### Verify

```bash
command -v gitkraken && echo OK
```

## Termius

SSH 客户端（GUI）。

### 安装

下载页：https://termius.com/linux （提供 snap 和 .deb）。

```bash
# .deb 路线
sudo apt-get install -y ~/Downloads/Termius-*.deb

# 或 snap 路线
sudo snap install termius-app
```

### Verify

```bash
command -v termius &>/dev/null || snap list | grep -q termius-app && echo OK
```

## Zotero

文献管理。上游 tar.xz，不进 apt。

### 安装

下载页：https://www.zotero.org/download/

```bash
sudo rm -rf /opt/zotero
sudo tar -xJf ~/Downloads/Zotero-*_linux-x86_64.tar.xz -C /opt
sudo mv /opt/Zotero_linux-x86_64 /opt/zotero
sudo /opt/zotero/set_launcher_icon
sudo ln -sf /opt/zotero/zotero.desktop /usr/share/applications/zotero.desktop
sudo ln -sf /opt/zotero/zotero          /usr/local/bin/zotero
sudo update-desktop-database /usr/share/applications 2>/dev/null || true
```

### 已知坑

- `set_launcher_icon` 必须跑 —— 它会修正 `.desktop` 里的绝对路径。
- 装完 GNOME 不会自动看到，跑 `update-desktop-database` 或注销重登。

### Verify

```bash
test -x /opt/zotero/zotero && command -v zotero && echo OK
```

## Miniconda

### 安装

```bash
# 装到 ~/miniconda3，避免和系统 Python 抢 PATH
wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
rm /tmp/miniconda.sh

# 让 conda 命令在当前 session 可用并把 init 写进 ~/.zshrc
"$HOME/miniconda3/bin/conda" init zsh
```

### **必做** —— 关闭 base 环境自动激活

```bash
"$HOME/miniconda3/bin/conda" config --set auto_activate_base false
```

### 已知坑

- **不关 `auto_activate_base`，每次开 shell 都会进 `(base)`，挡住别的 venv / nvm 提示**。这是设计这一节的核心动机。
- `conda init zsh` 修改 `~/.zshrc`；如果在 01-shell 里已经用项目 zshrc 覆盖过，**这一步必须在 zsh 配置生效之后跑**。
- 不要装 Anaconda 全家桶 —— 太重；要哪个包用 `conda install` 加。

### Verify

```bash
command -v conda &>/dev/null && \
  conda config --show auto_activate_base 2>/dev/null | grep -q 'False' && \
  echo OK
```

## Typora

Markdown 编辑器（付费但支持 Linux apt 仓库）。

### 安装

```bash
wget -qO - https://typora.io/linux/public-key.asc | \
  sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/typora.gpg
echo 'deb https://typora.io/linux ./' | \
  sudo tee /etc/apt/sources.list.d/typora.list
sudo apt-get update -qq && sudo apt-get install -y typora
```

### Verify

```bash
command -v typora && echo OK
```
