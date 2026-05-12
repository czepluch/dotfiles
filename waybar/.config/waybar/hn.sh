#!/bin/sh
# HackerNews top-stories cycler for waybar.
# Caches the top N story IDs + details for an hour, cycles display every 10 min
# via time-modulo. Truncates to fit the current monitor width.
#
# Usage: hn.sh [left|center]
#   left   -- show only on small monitors (< 4K width); hide on 4K
#   center -- show only on 4K monitors; hide on smaller ones
#   (no arg) -- show on every monitor (legacy behavior)

set -u

POSITION="${1:-any}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
CACHE_FILE="$CACHE_DIR/hn-stories.json"
URL_FILE="$CACHE_DIR/hn-url"
TOP_N=10
CYCLE_SECONDS=600
CACHE_MAX_AGE_MIN=60

mkdir -p "$CACHE_DIR"

# Pick truncation length per monitor width. Same WAYBAR_OUTPUT_NAME trick as netspeed.sh.
width=$(hyprctl monitors -j 2>/dev/null \
    | jq -r ".[] | select(.name == \"${WAYBAR_OUTPUT_NAME:-}\") | .width" 2>/dev/null)
case "$width" in
    ''|*[!0-9]*) width=0 ;;
esac

# Hide the instance that doesn't match this monitor's class.
case "$POSITION" in
    center)
        if [ "$width" -lt 3840 ]; then
            echo '{"text": "", "class": "hidden"}'
            exit 0
        fi
        ;;
    left)
        if [ "$width" -ge 3840 ]; then
            echo '{"text": "", "class": "hidden"}'
            exit 0
        fi
        ;;
esac

if [ "$width" -ge 3840 ]; then
    max_len=80
elif [ "$width" -ge 2560 ]; then
    max_len=70
else
    max_len=35
fi

# Refresh cache if missing or stale.
needs_refresh=0
if [ ! -s "$CACHE_FILE" ]; then
    needs_refresh=1
elif [ -n "$(find "$CACHE_FILE" -mmin +"$CACHE_MAX_AGE_MIN" 2>/dev/null)" ]; then
    needs_refresh=1
fi

if [ "$needs_refresh" -eq 1 ]; then
    ids=$(curl -fsS --max-time 5 "https://hacker-news.firebaseio.com/v0/topstories.json" 2>/dev/null \
          | jq -r ".[0:${TOP_N}] | .[]" 2>/dev/null)
    if [ -n "$ids" ]; then
        tmp=$(mktemp)
        # Fetch story details in parallel; one JSON object per line.
        echo "$ids" | xargs -n1 -P"$TOP_N" -I{} \
            curl -fsS --max-time 3 "https://hacker-news.firebaseio.com/v0/item/{}.json" \
            > "$tmp" 2>/dev/null
        if [ -s "$tmp" ] && jq -s '.' < "$tmp" > "$CACHE_FILE.new" 2>/dev/null; then
            mv "$CACHE_FILE.new" "$CACHE_FILE"
        fi
        rm -f "$tmp" "$CACHE_FILE.new"
    fi
fi

# If still no cache, render hidden so we don't leave junk in the bar.
if [ ! -s "$CACHE_FILE" ]; then
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

n=$(jq 'length' < "$CACHE_FILE" 2>/dev/null)
case "$n" in
    ''|*[!0-9]*) n=0 ;;
esac
if [ "$n" -lt 1 ]; then
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

idx=$(( ($(date +%s) / CYCLE_SECONDS) % n ))

story=$(jq -c ".[$idx]" < "$CACHE_FILE")
title=$(echo "$story" | jq -r '.title // ""')
url=$(echo "$story" | jq -r '.url // ("https://news.ycombinator.com/item?id=" + (.id|tostring))')
score=$(echo "$story" | jq -r '.score // 0')
by=$(echo "$story" | jq -r '.by // "?"')
comments=$(echo "$story" | jq -r '.descendants // 0')
hn_url="https://news.ycombinator.com/item?id=$(echo "$story" | jq -r '.id')"

printf '%s' "$url" > "$URL_FILE"

display="$title"
if [ "${#display}" -gt "$max_len" ]; then
    display="$(printf '%s' "$display" | cut -c1-$((max_len - 1)))…"
fi

text_json=$(printf '%s' "$display" | jq -Rs .)
tooltip_json=$(printf '%s\n\n%s points  %s comments  by %s\n%s\n%s' \
    "$title" "$score" "$comments" "$by" "$url" "$hn_url" | jq -Rs .)

printf '{"text": %s, "tooltip": %s, "class": "hn"}\n' "$text_json" "$tooltip_json"
