#!/usr/bin/env bash

# Get the current focused workspace
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

# Get the focused window ID
FOCUSED_WINDOW=$(aerospace list-windows --focused --format "%{window-id}")

# Remove existing window items
sketchybar --remove '/window\..*/'

# Get windows for the current workspace
WINDOWS=$(aerospace list-windows --workspace "$CURRENT_WORKSPACE" --format "%{window-id}|%{app-name}|%{window-title}")

if [ -n "$WINDOWS" ]; then
    # Counter for positioning
    COUNTER=0
    
    echo "$WINDOWS" | while IFS='|' read -r WINDOW_ID APP_NAME WINDOW_TITLE; do
        # Truncate long titles
        if [ ${#WINDOW_TITLE} -gt 25 ]; then
            WINDOW_TITLE="${WINDOW_TITLE:0:22}..."
        fi
        
        # Create display text
        DISPLAY_TEXT="$APP_NAME: $WINDOW_TITLE"
        
        # Determine if this is the focused window
        if [ "$WINDOW_ID" = "$FOCUSED_WINDOW" ]; then
            # Focused window styling
            sketchybar --add item "window.$WINDOW_ID" left \
                --set "window.$WINDOW_ID" \
                background.color=0xfff5a97f \
                background.corner_radius=6 \
                background.height=24 \
                icon="󰖯" \
                icon.color=0xff24273a \
                icon.padding_left=8 \
                icon.padding_right=5 \
                label="$DISPLAY_TEXT" \
                label.font="Agave Nerd Font Mono:Bold:12.0" \
                label.color=0xff24273a \
                label.padding_right=8 \
                click_script="aerospace focus --window-id $WINDOW_ID"
        else
            # Non-focused window styling
            sketchybar --add item "window.$WINDOW_ID" left \
                --set "window.$WINDOW_ID" \
                background.color=0x668bd5ca \
                background.corner_radius=6 \
                background.height=24 \
                icon="󰖲" \
                icon.color=0xff24273a \
                icon.padding_left=8 \
                icon.padding_right=5 \
                label="$DISPLAY_TEXT" \
                label.font="Agave Nerd Font Mono:Medium:12.0" \
                label.color=0xff24273a \
                label.padding_right=8 \
                click_script="aerospace focus --window-id $WINDOW_ID"
        fi
        
        COUNTER=$((COUNTER + 1))
    done
fi