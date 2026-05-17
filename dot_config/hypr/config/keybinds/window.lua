local variables = require("config.keybinds.variables")
local mod       = variables.mainMod

hl.config({
  binds = {
    allow_workspace_cycles            = true,
    workspace_back_and_forth          = true,
    workspace_center_on               = 1,
    movefocus_cycles_fullscreen       = true,
    window_direction_monitor_fallback = true,
  },
})

hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }),
  { description = "Toggle floating/tiling for the current window" })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),
  { mouse = true, description = "Drag the active window" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(),
  { mouse = true, description = "Resize the active window" })

hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }), { description = "Move active window to the left" })
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { description = "Move active window to the right" })
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }), { description = "Move active window upwards" })
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }), { description = "Move active window downwards" })

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "l" }), { description = "Move focus to the left" })
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Move focus to the right" })
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "u" }), { description = "Move focus upwards" })
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "d" }), { description = "Move focus downwards" })

local quickResize = {
  { "right", { 15,   0 } },
  { "left",  { -15,  0 } },
  { "up",    { 0,  -15 } },
  { "down",  { 0,   15 } },
  { "l",     { 15,   0 } },
  { "h",     { -15,  0 } },
  { "k",     { 0,  -15 } },
  { "j",     { 0,   15 } },
}
for _, r in ipairs(quickResize) do
  hl.bind(mod .. " + CTRL + SHIFT + " .. r[1],
    hl.dsp.window.resize({ x = r[2][1], y = r[2][2], relative = true }),
    { description = "Resize active window (" .. r[1] .. ")" })
end
