local variables = require("config.keybinds.variables")
local mod       = variables.mainMod

local raiseToWob = [[pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{if($1>100) system("pactl set-sink-volume @DEFAULT_SINK@ 100%")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]]
local lowerToWob = [[pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]]
local muteToWob  = [[amixer sset Master toggle | sed -En '/\[on\]/ s/.*\[([0-9]+)%\].*/\1/ p; /\[off\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]]

hl.bind(mod .. " + Prior", hl.dsp.exec_cmd(raiseToWob),
  { locked = true, repeating = true, description = "Raise volume by 5%" })
hl.bind(mod .. " + Next",  hl.dsp.exec_cmd(lowerToWob),
  { locked = true, repeating = true, description = "Lower volume by 5%" })

hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(muteToWob),
  { locked = true, repeating = true, description = "Toggle audio mute" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(raiseToWob),
  { locked = true, repeating = true, description = "Raise volume by 5%" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(lowerToWob),
  { locked = true, repeating = true, description = "Lower volume by 5%" })
