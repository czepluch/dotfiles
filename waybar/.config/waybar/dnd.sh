#!/bin/sh
# Do-not-disturb module for waybar, backed by mako modes.
#
# Usage: dnd.sh          - print current DND state as JSON for waybar
#        dnd.sh toggle   - flip mako's do-not-disturb mode, show a confirmation
#                          toast, and refresh this module
#
# State is runtime-only: mako modes reset when mako restarts (relogin/reboot).

set -u

MODE=do-not-disturb
SIGNAL=8   # must match "signal" for custom/dnd in config.jsonc

is_on() {
    makoctl mode 2>/dev/null | grep -qx "$MODE"
}

case "${1:-show}" in
    toggle)
        makoctl mode -t "$MODE" >/dev/null 2>&1
        # Confirmation toast. The app-name MUST be "notify-send" so mako's
        # [mode=do-not-disturb app-name=notify-send] invisible=false exception
        # lets it through even while DND is active.
        if is_on; then
            notify-send -a notify-send "Do not disturb: ON" "Notifications silenced"
        else
            notify-send -a notify-send "Do not disturb: OFF" "Notifications restored"
        fi
        # Refresh this waybar module immediately (RTMIN+SIGNAL).
        pkill -RTMIN+"$SIGNAL" waybar 2>/dev/null || true
        ;;
esac

# Icons: nf-md-bell_off (active) / nf-md-bell (inactive)
if is_on; then
    printf '{"text":"%s","tooltip":"Do not disturb: ON\\nClick to enable notifications","class":"active"}\n' '󰂛'
else
    printf '{"text":"%s","tooltip":"Do not disturb: OFF\\nClick to silence notifications","class":"inactive"}\n' '󰂚'
fi
