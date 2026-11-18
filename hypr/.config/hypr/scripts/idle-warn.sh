#!/usr/bin/env bash
# Idle warning: dims the laptop screen and turns the active border red
# before the screen locks. hypridle runs "start" at the warning timeout and
# "stop" on activity and after sleep. The border before the warning is kept
# in a state file and put back on stop. Only the border and brightness are
# touched, so settings raised at runtime (such as the lock screen's blur)
# stay as they are.

state="${XDG_RUNTIME_DIR:-/tmp}/idle-warn-border"

# Sets the active border from Hyprland's getoption format, for example
# "ff7dc9be ffffa745 ff269d96 90deg" (AARRGGBB colors, then the angle).
set_border() {
    local colors=() angle=0 token
    for token in $1; do
        if [[ $token =~ ^[0-9a-fA-F]{8}$ ]]; then
            colors+=("\"rgba(${token:2:6}${token:0:2})\"")
        elif [[ $token =~ ^([0-9.]+)deg$ ]]; then
            angle=${BASH_REMATCH[1]}
        fi
    done
    local IFS=,
    hyprctl eval "hl.config({general={col={active_border={colors={${colors[*]}},angle=$angle}}}})" >/dev/null
}

case "$1" in
    start)
        if [ ! -s "$state" ]; then
            hyprctl -j getoption general:col.active_border | jq -r .gradient > "$state"
        fi
        set_border "ffff3333 ffff0000 45deg"
        brightnessctl -s set 10%
        ;;
    stop)
        if [ -s "$state" ]; then
            set_border "$(cat "$state")"
            rm -f "$state"
        fi
        brightnessctl -r
        ;;
esac
