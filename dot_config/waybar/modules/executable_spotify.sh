#!/bin/bash

class=$(playerctl metadata --player=spotify --format '{{lc(status)}}')
icon=""

if [[ $class == "playing" ]]; then
  info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}}')
  if [[ ${#info} -gt 40 ]]; then
    info="${info:0:40}..."
  fi
  text="$info $icon"
elif [[ $class == "paused" ]]; then
  text="$icon"
elif [[ $class == "stopped" ]]; then
  text=""
fi

echo -e "{\"text\":\"$text\", \"class\":\"$class\"}"
