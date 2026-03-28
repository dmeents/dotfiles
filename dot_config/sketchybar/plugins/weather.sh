#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/sketchybar"
CACHE_FILE="$CACHE_DIR/weather.json"
CACHE_MAX_AGE=1800  # 30 minutes

mkdir -p "$CACHE_DIR"

# Use cached data if fresh enough
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -f '%m' "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [[ $CACHE_AGE -lt $CACHE_MAX_AGE ]]; then
        WEATHER_JSON=$(cat "$CACHE_FILE")
    fi
fi

# Fetch fresh data if cache is stale or missing
if [[ -z "$WEATHER_JSON" ]]; then
    LOCATION_JSON=$(curl -s --max-time 5 "https://ipinfo.io/json" 2>/dev/null)
    if [[ -z "$LOCATION_JSON" ]]; then
        sketchybar --set "$NAME" label="Weather unavailable"
        exit 0
    fi

    LOCATION="$(echo "$LOCATION_JSON" | jq -r '.city // empty')"
    REGION="$(echo "$LOCATION_JSON" | jq -r '.region // empty')"

    LOCATION_ESCAPED="${LOCATION// /+}+${REGION// /+}"
    WEATHER_JSON=$(curl -s --max-time 5 "https://wttr.in/${LOCATION_ESCAPED}?format=j1" 2>/dev/null)

    if [[ -n "$WEATHER_JSON" ]]; then
        echo "$WEATHER_JSON" > "$CACHE_FILE"
    fi
fi

# Fallback if still empty
if [[ -z "$WEATHER_JSON" ]]; then
    sketchybar --set "$NAME" label="Weather unavailable"
    exit 0
fi

TEMPERATURE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_C // empty')
WEATHER_DESCRIPTION=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value // empty' | cut -c1-25)
LOCATION=$(echo "$WEATHER_JSON" | jq -r '.nearest_area[0].areaName[0].value // empty')
MOON_PHASE=$(echo "$WEATHER_JSON" | jq -r '.weather[0].astronomy[0].moon_phase // empty')

case "${MOON_PHASE}" in
"New Moon")        ICON= ;;
"Waxing Crescent") ICON= ;;
"First Quarter")   ICON= ;;
"Waxing Gibbous")  ICON= ;;
"Full Moon")       ICON= ;;
"Waning Gibbous")  ICON= ;;
"Last Quarter")    ICON= ;;
"Waning Crescent") ICON= ;;
*)                 ICON= ;;
esac

sketchybar --set "$NAME" label="$LOCATION  ${TEMPERATURE}℃ $WEATHER_DESCRIPTION"
sketchybar --set "$NAME.moon" icon="$ICON"
