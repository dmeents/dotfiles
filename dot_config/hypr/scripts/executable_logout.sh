#!/bin/bash

# Gracefully kill stubborn applications before logout
APPS_TO_KILL=("gitkraken" "beepertexts")

for app in "${APPS_TO_KILL[@]}"; do
    if pgrep -x "$app" > /dev/null; then
        echo "Terminating $app..."
        pkill -TERM "$app"
    fi
done

# Give apps 2 seconds to close gracefully
sleep 2

# Force kill if still running
for app in "${APPS_TO_KILL[@]}"; do
    if pgrep -x "$app" > /dev/null; then
        echo "Force killing $app..."
        pkill -KILL "$app"
    fi
done

# Exit Hyprland
hyprctl dispatch exit
