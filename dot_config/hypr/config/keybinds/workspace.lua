local variables = require("config.keybinds.variables")
local mod       = variables.mainMod

for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }),
    { description = "Switch to workspace " .. i })
  hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }),
    { description = "Move window and switch to workspace " .. i })
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, silent = true }),
    { description = "Move window silently to workspace " .. i })
end

hl.bind(mod .. " + CTRL + left",  hl.dsp.window.move({ workspace = "-1" }),
  { description = "Move window and switch to the previous workspace" })
hl.bind(mod .. " + CTRL + right", hl.dsp.window.move({ workspace = "+1" }),
  { description = "Move window and switch to the next workspace" })

hl.bind(mod .. " + PERIOD", hl.dsp.focus({ workspace = "e+1" }),
  { description = "Scroll through workspaces incrementally" })
hl.bind(mod .. " + COMMA",  hl.dsp.focus({ workspace = "e-1" }),
  { description = "Scroll through workspaces decrementally" })

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }),
  { description = "Scroll through workspaces incrementally" })
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }),
  { description = "Scroll through workspaces decrementally" })

hl.bind(mod .. " + slash", hl.dsp.focus({ workspace = "previous" }),
  { description = "Switch to the previous workspace" })

-- Special workspaces (scratchpads)
hl.bind(mod .. " + minus", hl.dsp.window.move({ workspace = "special" }),
  { description = "Move active window to Special workspace" })
hl.bind(mod .. " + equal", hl.dsp.workspace.toggle_special("special"),
  { description = "Toggle the Special workspace" })
hl.bind(mod .. " + F1", hl.dsp.workspace.toggle_special("scratchpad"),
  { description = "Toggle the scratchpad special workspace" })
hl.bind(mod .. " + ALT + SHIFT + F1",
  hl.dsp.window.move({ workspace = "special:scratchpad", silent = true }),
  { description = "Move active window silently to the scratchpad special workspace" })
