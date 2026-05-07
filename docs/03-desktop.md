# 03 — 桌面外观（主题 / 扩展 / GNOME 设置）

GTK 主题 + 图标 + 鼠标 + GNOME 扩展 + 字体/缩放/壁纸。

## GTK 主题：Orchis

```bash
mkdir -p ~/.themes
tmp=$(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git "$tmp/Orchis-theme"
( cd "$tmp/Orchis-theme" && ./install.sh -d ~/.themes )
rm -rf "$tmp"
```

## 图标主题：Tela (blue 变体)

```bash
mkdir -p ~/.icons
tmp=$(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/Tela-icon-theme.git "$tmp/Tela-icon-theme"
( cd "$tmp/Tela-icon-theme" && ./install.sh -d ~/.icons blue )
rm -rf "$tmp"
```

## 鼠标主题：Bibata Modern Ice

```bash
tmp=$(mktemp -d)
wget -q -P "$tmp" \
  https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
mkdir -p ~/.icons
tar -xf "$tmp/Bibata-Modern-Ice.tar.xz" -C ~/.icons/
rm -rf "$tmp"
```

## GNOME 扩展工具

```bash
sudo apt-get install -y gnome-tweaks gnome-shell-extension-manager dconf-cli
```

**推荐扩展**（用 Extension Manager GUI 装；apt 里没有）：

- Blur my Shell — https://extensions.gnome.org/extension/3193/blur-my-shell/
- Dash to Dock  — https://extensions.gnome.org/extension/307/dash-to-dock/
- Just Perfection — https://extensions.gnome.org/extension/3843/just-perfection/
- User Themes   — https://extensions.gnome.org/extension/19/user-themes/

## 应用 GNOME 设置（gsettings + dconf）

```bash
gsettings set org.gnome.desktop.interface icon-theme       'Tela-blue'
gsettings set org.gnome.desktop.interface cursor-theme     'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface cursor-size      48
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.interface font-name        'Ubuntu Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Sans Mono 13'

dconf load /org/gnome/desktop/interface/  < configs/default/gnome_settings/gnome-interface.dconf
dconf load /org/gnome/shell/extensions/   < configs/default/gnome_extensions/gnome-extensions.dconf
```

## 壁纸

```bash
mkdir -p ~/Pictures
cp configs/default/wallpaper/*.jpg ~/Pictures/
wp=~/Pictures/wallhaven-21yzzx.jpg
gsettings set org.gnome.desktop.background picture-uri      "file://$wp"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp"
```

## 已知坑

- **Dash to Dock 必须先在 Extension Manager 里装好**，再 `dconf load gnome-extensions.dconf` —— 否则 dconf 写的是空白 schema，扩展装上后这些设置不会被应用。
- `text-scaling-factor 1.25` 是高 DPI 屏的设定；外接 1080p 显示器要改回 `1.0`。
- Bibata `cursor-size 48` 适配缩放后的桌面；不缩放就用 `24`。

## Verify

```bash
test -d ~/.themes/Orchis && \
  test -d ~/.icons/Tela-blue && \
  test -d ~/.icons/Bibata-Modern-Ice && \
  command -v gnome-tweaks &>/dev/null && \
  echo OK
```
