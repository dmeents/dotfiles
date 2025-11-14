#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on
    # Update window names when workspace changes
    ~/.config/sketchybar/plugins/window_names.sh
else
    sketchybar --set $NAME background.drawing=off
fi
