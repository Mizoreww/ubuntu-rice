# 06 — 其他应用

Chrome, VLC, OBS Studio, FileZilla。

## Google Chrome

### 安装

```bash
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  -O /tmp/chrome.deb
sudo apt-get install -y /tmp/chrome.deb
rm /tmp/chrome.deb
```

### Verify

```bash
command -v google-chrome && echo OK
```

## VLC

```bash
sudo apt-get install -y vlc
```

### Verify

```bash
command -v vlc && echo OK
```

## OBS Studio

### 安装

```bash
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo apt-get update -qq
sudo apt-get install -y obs-studio
```

### Verify

```bash
command -v obs && echo OK
```

## FileZilla（必须走 apt / GTK3）

### 安装

```bash
sudo apt-get install -y filezilla
```

### 已知坑

- **绝对不要用 https://filezilla-project.org 上游 tarball** —— 它绑定的是 wxWidgets-GTK2，在现代 Ubuntu + fcitx5 下文本输入框光标完全不可见。
- apt 仓库里的 `filezilla` 链接的是 `wxgtk3`，是 **GTK3** 构建，没这个 bug。
- 老 `install-apps.sh` 之前从 Downloads 装 GTK2 tarball 翻车过 —— 已废弃，统一走 apt。

### Verify

```bash
command -v filezilla && \
  ldd "$(command -v filezilla)" 2>/dev/null | grep -q 'wxgtk3\|gtk-3' && \
  echo OK
```
