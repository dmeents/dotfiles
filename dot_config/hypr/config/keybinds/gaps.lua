local variables = require("config.keybinds.variables")
local mod       = variables.mainMod

hl.bind(mod .. " + SHIFT + G",
  hl.dsp.exec_cmd([[hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"]]),
  { description = "Set CachyOS default gaps" })

hl.bind(mod .. " + G",
  hl.dsp.exec_cmd([[hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"]]),
  { description = "Remove gaps between windows" })
