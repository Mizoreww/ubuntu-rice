#!/bin/bash
# One-shot helper: install ghostty + clipboard tools + nautilus integration.
#
# Ghostty's deb ships its own nautilus extension at
# /usr/share/nautilus-python/extensions/ghostty.py — we only need
# python3-nautilus on the system for it to load. xclip / wl-clipboard
# are required for TUI apps (Claude Code, fzf, etc.) to reach the
# system clipboard on X11 / Wayland.
#
# Run with:  bash ~/Desktop/ubuntu-rice/install-ghostty.sh
set -e

echo "[1/4] Adding ppa:mkasberg/ghostty-ubuntu..."
sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu

echo "[2/4] apt update + install ghostty + nautilus + clipboard tools..."
sudo apt-get update -qq
sudo apt-get install -y ghostty python3-nautilus xclip wl-clipboard

# Remove the gnome-terminal nautilus extension so right-click shows
# only one "Open in Terminal" entry (Ghostty's own).
sudo apt-get remove -y nautilus-extension-gnome-terminal 2>/dev/null || true

GHOSTTY_BIN="$(command -v ghostty)"
echo "[3/4] Setting ghostty as default terminal ($GHOSTTY_BIN)..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
    x-terminal-emulator "$GHOSTTY_BIN" 60
sudo update-alternatives --set x-terminal-emulator "$GHOSTTY_BIN"

# GNOME 42+ honors this; older versions ignore it harmlessly.
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty' 2>/dev/null || true

echo "[4/4] Restarting Nautilus to pick up the bundled Ghostty extension..."
nautilus -q 2>/dev/null || true

echo
echo "Done. Verify: $(ghostty --version 2>&1 | head -1)"
echo "Right-click in Files should now show exactly one 'Open in Ghostty'."
