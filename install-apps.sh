#!/bin/bash
# install-apps.sh — one-shot installer for the Downloads bundle + VLC.
#
# Run with:
#   bash ~/Desktop/ubuntu-rice/install-apps.sh
# (or `! bash ...` from inside Claude Code to keep the password in TTY)
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "This script needs root. Re-running under sudo..." >&2
    exec sudo -E bash "$0" "$@"
fi

# Resolve the invoking user's home so /opt installs and Downloads paths still
# point at the real user's files when we're running as root.
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

DL="${REAL_HOME}/Downloads"

# ── apt bundle: .deb files + VLC + FileZilla ────────────────────────────
# `apt install ./pkg.deb` resolves dependencies automatically, unlike
# raw `dpkg -i` which leaves the system in a half-broken state on miss.
# FileZilla goes through apt (not the upstream tarball) because the tarball
# bundles wxWidgets-GTK2, which renders an invisible text caret on modern
# Ubuntu — apt's build links wxgtk3 and avoids the issue.
echo "[1/3] Installing .deb packages, VLC, and FileZilla via apt..."
apt-get update -qq
apt-get install -y vlc filezilla \
    "${DL}/code_1.118.0-1777427473_amd64.deb" \
    "${DL}/gitkraken-amd64.deb" \
    "${DL}/baidunetdisk_4.17.8_amd64.deb" \
    "${DL}/splayer-3.0.0-amd64.deb" \
    "${DL}/todesk-v4.8.6.2-amd64.deb"

# ── Zotero (tar.xz → /opt, uses bundled launcher script) ────────────────
echo "[2/3] Installing Zotero to /opt/zotero..."
rm -rf /opt/zotero
tar -xJf "${DL}/Zotero-9.0.1_linux-x86_64.tar.xz" -C /opt
mv /opt/Zotero_linux-x86_64 /opt/zotero
# Zotero ships a script that fixes absolute paths inside zotero.desktop.
/opt/zotero/set_launcher_icon
ln -sf /opt/zotero/zotero.desktop /usr/share/applications/zotero.desktop
ln -sf /opt/zotero/zotero /usr/local/bin/zotero

# ── Refresh icon + desktop database so GNOME picks everything up ───────
echo "[3/3] Refreshing desktop database..."
update-desktop-database /usr/share/applications 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true

echo
echo "Done. Verify installs:"
for cmd in vlc code gitkraken baidunetdisk splayer todesk filezilla zotero; do
    if command -v "$cmd" &>/dev/null; then
        printf "  ✓ %s\n" "$cmd"
    else
        printf "  ✗ %s (not found in PATH — check Activities menu)\n" "$cmd"
    fi
done
