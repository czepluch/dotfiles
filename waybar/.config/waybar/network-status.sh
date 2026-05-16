#!/bin/sh
# Network SSID module - compact on small displays, full on 4K.
# Auto-detects the managed wifi interface so it works across hosts.

WIFI_IF=$(iw dev 2>/dev/null | awk '$1=="Interface"{iface=$2} $1=="type" && $2=="managed"{print iface; exit}')

ssid=""
[ -n "$WIFI_IF" ] && ssid=$(iw dev "$WIFI_IF" link 2>/dev/null | awk -F': ' '/SSID:/{print $2}')

if [ -z "$ssid" ]; then
    if ip route | grep -q default; then
        echo '{"text": "󰈀 Wired", "tooltip": "Ethernet connected", "class": "ethernet"}'
    else
        echo '{"text": "󰤭 Off", "tooltip": "Disconnected", "class": "disconnected"}'
    fi
    exit 0
fi

ip_addr=$(ip -4 addr show "$WIFI_IF" 2>/dev/null | awk '/inet /{print $2}')
gateway=$(ip route | awk -v dev="$WIFI_IF" '/default/ && $5==dev {print $3}')
width=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$WAYBAR_OUTPUT_NAME\") | .width")

if [ "${width:-0}" -ge 3840 ]; then
    display="$ssid"
else
    len=${#ssid}
    if [ "$len" -le 12 ]; then
        display="$ssid"
    else
        display="${ssid:0:5}..${ssid: -5}"
    fi
fi

printf '{"text": "󰤨 %s", "tooltip": "%s\\n%s\\nGateway: %s", "class": "wifi"}\n' \
    "$display" "$ssid" "$ip_addr" "$gateway"
