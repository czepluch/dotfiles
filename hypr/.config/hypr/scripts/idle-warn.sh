#!/usr/bin/env bash
# Idle warning: dims laptop + flashes border red before screen lock
# Used by hypridle as a pre-lock visual warning

case "$1" in
    start)
        hyprctl keyword general:col.active_border "rgba(ff3333ff) rgba(ff0000ff) 45deg"
        brightnessctl -s set 10%
        ;;
    stop)
        hyprctl reload
        brightnessctl -r
        ;;
esac
