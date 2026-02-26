#!/bin/sh
# Network speed module - only shows on 4K displays, hidden on small ones

width=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$WAYBAR_OUTPUT_NAME\") | .width")

if [ "${width:-0}" -lt 3840 ]; then
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

iface=$(ip route | awk '/default/{print $5; exit}')
if [ -z "$iface" ]; then
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

rx1=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)
sleep 1
rx2=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)

rate=$(( (rx2 - rx1) ))

if [ "$rate" -ge 1048576 ]; then
    display=$(awk "BEGIN {printf \"%.1f MB/s\", $rate / 1048576}")
elif [ "$rate" -ge 1024 ]; then
    display=$(awk "BEGIN {printf \"%.0f KB/s\", $rate / 1024}")
else
    display="${rate} B/s"
fi

printf '{"text": "󰇚%s", "tooltip": "Download speed", "class": "speed"}\n' "$display"
