#!/usr/bin/env bash
# power-menu.sh - session menu on SUPER+M, rendered by fuzzel so it follows the
# active theme (colors/border/font come from ~/.config/themes/current/fuzzel.ini).
# Entries execute immediately on Enter; Escape cancels.

set -euo pipefail

choice=$(printf '%s\n' \
    "󰌾  Lock" \
    "󰍃  Logout" \
    "󰒲  Suspend" \
    "󰜉  Reboot" \
    "󰐥  Poweroff" \
    | fuzzel --dmenu --prompt "session: " --lines 5 --width 24) || exit 0

case "$choice" in
    *Lock*)     hyprlock ;;
    *Logout*)   hyprctl dispatch exit ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Poweroff*) systemctl poweroff ;;
esac
