#!/bin/sh
# Power-profiles-daemon module for waybar.
#
# Usage: ppd.sh         - print current profile as JSON for waybar
#        ppd.sh cycle   - rotate to the next profile (power-saver -> balanced
#                         -> performance -> power-saver) and print the new one

set -u

ACTION="${1:-show}"
profile=$(powerprofilesctl get 2>/dev/null) || profile=unknown

case "$ACTION" in
    cycle)
        case "$profile" in
            power-saver) next=balanced ;;
            balanced)    next=performance ;;
            performance) next=power-saver ;;
            *)           next=balanced ;;
        esac
        powerprofilesctl set "$next" >/dev/null 2>&1
        profile=$next
        ;;
esac

# Icons: nf-md-speedometer / nf-md-heart_pulse / nf-md-power_plug_off
case "$profile" in
    performance) icon='󰓅'; class=performance ;;
    balanced)    icon='󰾅'; class=balanced ;;
    power-saver) icon='󰌪'; class=power-saver ;;
    *)           icon='?';  class=unknown ;;
esac

printf '{"text":"%s","tooltip":"Power profile: %s\\nClick to cycle","class":"%s"}\n' \
    "$icon" "$profile" "$class"
