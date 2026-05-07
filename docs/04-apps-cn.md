# 04 — 中文应用

QQ、微信、网易云音乐、百度网盘、SPlayer、ToDesk。

## 通用模式：`apt install ./xxx.deb`

中文桌面应用大多以 `.deb` 形式分发。固定流程：

```bash
# 1. 从官网下载 .deb 到 ~/Downloads（必要时让用户提供链接）
# 2. 用 apt 装 —— 不要用 dpkg -i，遇缺依赖会卡住
sudo apt-get install -y ./xxx.deb
```

## QQ

### 安装

下载页：https://im.qq.com/linuxqq/index.shtml （选 amd64 .deb）

```bash
sudo apt-get install -y ~/Downloads/QQ_*_amd64.deb
```

### Verify

```bash
command -v qq &>/dev/null || test -f /usr/share/applications/qq.desktop && echo OK
```

## 微信（Linux 原生版）

### 安装

下载页：https://weixin.qq.com/?platform=linux （`.deb` 包）

```bash
sudo apt-get install -y ~/Downloads/WeChat_*_amd64.deb
```

### 已知坑

- 必须用**官方原生 Linux 版**（基于 Electron，腾讯自己出的），不是 wine/deepin-wine 套壳。
- 安装完首次运行可能要扫码登录；扫描时关闭 fcitx5 避免输入法干扰。

### Verify

```bash
test -f /usr/share/applications/wechat.desktop && echo OK
```

## 网易云音乐

### 安装

官方包久未更新，常用社区维护版本：https://github.com/PIPIPIG233666/netease-cloud-music-gtk-rs/releases （或用户自选）。如果用户已经有官方 `.deb`：

```bash
sudo apt-get install -y ~/Downloads/netease-cloud-music_*_amd64.deb
```

### Verify

```bash
test -f /usr/share/applications/netease-cloud-music.desktop && echo OK
```

## 百度网盘

### 安装

下载页：https://pan.baidu.com/download （Linux 客户端 .deb）

```bash
sudo apt-get install -y ~/Downloads/baidunetdisk_*_amd64.deb
```

### 已知坑

- 装完 `baidunetdisk` 命令**不在 PATH**里，但 `Activities` 菜单里能搜到。这是上游打包问题，不是装错了。

### Verify

```bash
test -f /usr/share/applications/baidunetdisk.desktop && echo OK
```

## SPlayer（GitHub releases）

> 与老 `install-apps.sh` 不同 —— 改为从 GitHub releases 直接装。

### 安装

下载页：https://github.com/imsyy/SPlayer/releases （选 `splayer*amd64.deb`）

```bash
sudo apt-get install -y ~/Downloads/splayer-*-amd64.deb
```

### Verify

```bash
test -f /usr/share/applications/SPlayer.desktop && echo OK
```

## ToDesk

### 安装

下载页：https://www.todesk.com/linux.html （`.deb`）

```bash
sudo apt-get install -y ~/Downloads/todesk-*-amd64.deb
```

### Verify

```bash
command -v todesk &>/dev/null && echo OK
```
