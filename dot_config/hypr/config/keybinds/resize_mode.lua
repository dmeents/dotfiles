local variables = require("config.keybinds.variables")
local mod       = variables.mainMod

hl.define_submap("resize", function()
  local steps = {
    { "right", 15,   0   },
    { "left",  -15,  0   },
    { "up",    0,    -15 },
    { "down",  0,    15  },
    { "l",     15,   0   },
    { "h",     -15,  0   },
    { "k",     0,    -15 },
    { "j",     0,    15  },
  }
  for _, s in ipairs(steps) do
    hl.bind(s[1],
      hl.dsp.window.resize({ x = s[2], y = s[3], relative = true }),
      { repeating = true, description = "Resize active window (" .. s[1] .. ")" })
  end

  hl.bind("escape", hl.dsp.submap("reset"),
    { description = "Exit resize mode" })
end)

hl.bind(mod .. " + R", hl.dsp.submap("resize"),
  { description = "Enter window-resize mode" })
