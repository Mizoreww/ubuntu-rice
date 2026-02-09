#!/bin/bash
# utils.sh - Common utility functions for ubuntu-rice
# Sourced by install.sh and other scripts; do not execute directly.

# ── Project root directory ───────────────────────────────────────────────
# Resolve the absolute path of the project regardless of where the caller
# script lives. Works even through symlinks.
if [[ -z "${PROJECT_DIR:-}" ]]; then
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# ── Color constants ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Logging helpers ──────────────────────────────────────────────────────

log_info() {
    printf "${BLUE}[INFO]${NC}  %s\n" "$*"
}

log_success() {
    printf "${GREEN}[OK]${NC}    %s\n" "$*"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC}  %s\n" "$*"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$*" >&2
}

# ── get_config_dir ───────────────────────────────────────────────────────
# Return the config directory for a module.
# If configs/custom/<name> exists, prefer it; otherwise fall back to
# configs/default/<name>. Prints nothing and returns 1 if neither exists.
get_config_dir() {
    local name="$1"
    local custom="${PROJECT_DIR}/configs/custom/${name}"
    local default="${PROJECT_DIR}/configs/default/${name}"

    if [[ -d "$custom" ]]; then
        echo "$custom"
        return 0
    elif [[ -d "$default" ]]; then
        echo "$default"
        return 0
    else
        return 1
    fi
}

# ── ensure_cmd ───────────────────────────────────────────────────────────
# Check that a command exists on the system.
ensure_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: $cmd"
        return 1
    fi
}

# ── print_banner ─────────────────────────────────────────────────────────
# Print a boxed title banner.
print_banner() {
    local title="$1"
    local len=${#title}
    local border
    border=$(printf '─%.0s' $(seq 1 $((len + 4))))

    echo ""
    printf "${CYAN}┌%s┐${NC}\n" "$border"
    printf "${CYAN}│  ${BOLD}%s${NC}${CYAN}  │${NC}\n" "$title"
    printf "${CYAN}└%s┘${NC}\n" "$border"
    echo ""
}
