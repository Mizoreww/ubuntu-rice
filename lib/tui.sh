#!/bin/bash
# tui.sh - Whiptail-based TUI wrappers
# Sourced by install.sh; do not execute directly.

# ── Terminal dimensions (refreshed once on source) ───────────────────────
TERM_LINES="$(tput lines 2>/dev/null || echo 24)"
TERM_COLS="$(tput cols 2>/dev/null || echo 80)"

# Clamp dimensions for whiptail (leave room for borders)
_TUI_HEIGHT=$(( TERM_LINES - 4 ))
_TUI_WIDTH=$(( TERM_COLS - 8 ))
(( _TUI_HEIGHT < 12 )) && _TUI_HEIGHT=12
(( _TUI_WIDTH  < 40 )) && _TUI_WIDTH=40

# ── tui_msgbox ───────────────────────────────────────────────────────────
# Show an informational dialog.
# Usage: tui_msgbox "Title" "Message body"
tui_msgbox() {
    local title="$1"
    local message="$2"
    whiptail --title "$title" --msgbox "$message" "$_TUI_HEIGHT" "$_TUI_WIDTH"
}

# ── tui_yesno ────────────────────────────────────────────────────────────
# Ask the user a yes/no question. Returns 0 for yes, 1 for no.
# Usage: if tui_yesno "Confirm" "Proceed?"; then ...
tui_yesno() {
    local title="$1"
    local message="$2"
    whiptail --title "$title" --yesno "$message" "$_TUI_HEIGHT" "$_TUI_WIDTH"
}

# ── tui_checklist ────────────────────────────────────────────────────────
# Present a checklist and print the selected tags to stdout.
#
# Usage:
#   items=("tag1" "Description 1" "ON" "tag2" "Description 2" "OFF")
#   selected=$(tui_checklist "Pick components" "${items[@]}")
#
# Each item is a triple: tag, description, ON/OFF.
tui_checklist() {
    local title="$1"
    shift
    local items=("$@")
    local count=$(( ${#items[@]} / 3 ))

    # Compute list height (items shown at once)
    local list_height=$(( _TUI_HEIGHT - 8 ))
    (( list_height > count )) && list_height=$count
    (( list_height < 1 )) && list_height=1

    local result
    result=$(whiptail --title "$title" \
        --checklist "Use SPACE to toggle, ENTER to confirm:" \
        "$_TUI_HEIGHT" "$_TUI_WIDTH" "$list_height" \
        "${items[@]}" \
        3>&1 1>&2 2>&3) || return 1

    # whiptail returns tags in double quotes; strip them
    echo "$result" | tr -d '"'
}

# ── tui_show_result ──────────────────────────────────────────────────────
# Display a result summary after installation / uninstallation.
#
# Usage:
#   results=("kitty:ok" "zsh:ok" "fonts:fail")
#   tui_show_result "${results[@]}"
tui_show_result() {
    local results=("$@")
    local body=""
    local ok_count=0
    local fail_count=0

    for entry in "${results[@]}"; do
        local name="${entry%%:*}"
        local status="${entry#*:}"
        if [[ "$status" == "ok" ]]; then
            body+="  [OK]   ${name}\n"
            (( ok_count++ ))
        else
            body+="  [FAIL] ${name}\n"
            (( fail_count++ ))
        fi
    done

    body+="\n-----------------------------\n"
    body+="  Succeeded: ${ok_count}   Failed: ${fail_count}"

    whiptail --title "Results" --msgbox "$body" "$_TUI_HEIGHT" "$_TUI_WIDTH"
}
