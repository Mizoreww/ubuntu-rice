# 02 — 输入法 + 系统语言

中文拼音 (fcitx5) + 系统切到 zh_CN.UTF-8，但保持 `~/Desktop` `~/Downloads` 等 XDG 目录是英文。

## fcitx5

### 安装

```bash
sudo apt-get install -y \
    fcitx5 fcitx5-chinese-addons fcitx5-material-color fcitx5-config-qt

# 注册 fcitx5 为活动 IM 框架（写 ~/.xinputrc）
im-config -n fcitx5 || true

# 登录自启
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/fcitx5.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx 5
GenericName=Input Method
Comment=Start Input Method
Exec=fcitx5 -d
Icon=fcitx
Terminal=false
Categories=System;Utility;
StartupNotify=false
X-GNOME-Autostart-Phase=Applications
X-GNOME-AutoRestart=false
X-GNOME-Autostart-Notify=false
X-KDE-autostart-after=panel
EOF

# 把 fcitx5/pinyin 加进 GNOME input-sources（不加这一步 IM 默认不激活）
current="$(dconf read /org/gnome/desktop/input-sources/sources 2>/dev/null || echo '')"
if [[ "$current" != *"'pinyin'"* ]]; then
    if [[ -z "$current" || "$current" == "@a(ss) []" ]]; then
        dconf write /org/gnome/desktop/input-sources/sources \
            "[('xkb', 'us'), ('fcitx', 'pinyin')]"
    else
        merged="${current%]}, ('fcitx', 'pinyin')]"
        dconf write /org/gnome/desktop/input-sources/sources "$merged"
    fi
fi

# 立刻起来，不用注销
pgrep -x fcitx5 >/dev/null || (nohup fcitx5 -d &>/dev/null & disown)
```

### 配置

```bash
mkdir -p ~/.config/fcitx5/conf
cp configs/default/fcitx5/*.conf ~/.config/fcitx5/conf/

# 重启 fcitx5 让配置生效
pidof fcitx5 >/dev/null && fcitx5 -r -d &
```

### 已知坑

- `im-config` 必须以普通用户跑（不能 sudo），它写的是 `~/.xinputrc`。
- 不加 `dconf` 那一步，登录后 IM 看似装好但**实际没激活**。
- `fcitx5-config-qt` 提供 GUI 配置工具；不装也能用，但自查问题麻烦。
- 切换输入法快捷键默认是 **Ctrl+Space**。

### Verify

```bash
dpkg -l fcitx5 &>/dev/null && \
  test -f ~/.config/autostart/fcitx5.desktop && \
  test -f ~/.config/fcitx5/conf/pinyin.conf && \
  echo OK
```

## 系统语言：zh_CN.UTF-8 + 英文 XDG 目录

### 安装

```bash
sudo apt-get install -y \
    language-pack-zh-hans language-pack-gnome-zh-hans \
    fonts-noto-cjk fonts-noto-cjk-extra

sudo locale-gen zh_CN.UTF-8 en_US.UTF-8
sudo update-locale LANG=zh_CN.UTF-8 LANGUAGE="zh_CN:zh:en_US:en"

# 把 XDG 目录锁成英文 —— 不然下次登录 GNOME 会问"是否把 ~/Desktop 重命名为 ~/桌面"
mkdir -p ~/.config
echo "en_US" > ~/.config/user-dirs.locale
LC_ALL=C LANG=en_US.UTF-8 xdg-user-dirs-update --force || true
```

### 已知坑

- `update-locale` 改的是 `/etc/default/locale`，**注销重登才生效**。
- `LANGUAGE="zh_CN:zh:en_US:en"` 留英文 fallback，避免某些系统消息出现 missing translation 占位符。
- `user-dirs.locale` 必须在第一次登录前写好，否则 GNOME 会弹出重命名提示框。

### Verify

```bash
grep -q 'LANG=zh_CN.UTF-8' /etc/default/locale && \
  [ "$(cat ~/.config/user-dirs.locale 2>/dev/null)" = "en_US" ] && \
  echo OK
```
