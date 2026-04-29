#!/bin/bash
# fix-now.sh — apply the live-machine portion of the locale + clipboard +
# nautilus fix. Idempotent: safe to re-run.
#
# Run with:
#   echo 'YOUR_PASSWORD' | bash ~/Desktop/ubuntu-rice/fix-now.sh
# (the password is piped in once and used by every sudo step inside)
set -e
PASS="$(cat)"

echo "[1/4] apt update + install python3-nautilus, clipboard tools, language packs..."
echo "$PASS" | sudo -S -p "" bash -c '
    apt-get update -qq
    apt-get install -y python3-nautilus xclip wl-clipboard \
        language-pack-zh-hans language-pack-gnome-zh-hans \
        fonts-noto-cjk fonts-noto-cjk-extra
'

echo "[2/4] Removing nautilus-extension-gnome-terminal (avoids duplicate menu entry)..."
echo "$PASS" | sudo -S -p "" apt-get remove -y nautilus-extension-gnome-terminal || true

echo "[3/4] Generating zh_CN.UTF-8 locale and switching system LANG..."
echo "$PASS" | sudo -S -p "" bash -c '
    locale-gen zh_CN.UTF-8 en_US.UTF-8
    update-locale LANG=zh_CN.UTF-8 LANGUAGE="zh_CN:zh:en_US:en"
'

echo "[4/4] Pinning XDG user directories to English..."
mkdir -p "${HOME}/.config"
echo "en_US" > "${HOME}/.config/user-dirs.locale"
LC_ALL=C LANG=en_US.UTF-8 xdg-user-dirs-update --force 2>/dev/null || true

# Ghostty's deb already provides /usr/share/nautilus-python/extensions/ghostty.py;
# python3-nautilus (installed above) is the only thing it needs to load.
nautilus -q 2>/dev/null || true

echo
echo "Done. Log out and back in for:"
echo "  - Chinese system UI (XDG dirs stay English)"
echo "  - Single 'Open in Ghostty' entry in Files right-click menu"
echo "  - Clipboard works for TUI apps (Claude Code etc.) on X11/Wayland"
