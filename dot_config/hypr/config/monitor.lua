local machine = require("config.machine")

if machine.type == "desktop" then
  hl.monitor({ output = "DP-1", mode = "6144x2560@120", position = "0x0",       scale = 1 })
  hl.monitor({ output = "DP-6", mode = "2048x2560@120", position = "0x0",       scale = 1 })
  hl.monitor({ output = "DP-7", mode = "4096x2560@60",  position = "auto-right", scale = 1 })

  hl.workspace_rule({ workspace = "1", monitor = "DP-1", persistent = true })
  hl.workspace_rule({
    workspace   = "2",
    monitor     = "DP-1",
    persistent  = true,
    layout      = "master",
    layout_opts = { orientation = "right" },
  })
  hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true })
  hl.workspace_rule({ workspace = "4", monitor = "DP-6", persistent = true })
  hl.workspace_rule({ workspace = "5", monitor = "DP-6", persistent = true })
  hl.workspace_rule({ workspace = "6", monitor = "DP-6", persistent = true })
  hl.workspace_rule({ workspace = "7", monitor = "DP-7", persistent = true })
  hl.workspace_rule({ workspace = "8", monitor = "DP-7", persistent = true })
  hl.workspace_rule({ workspace = "9", monitor = "DP-7", persistent = true })
elseif machine.type == "laptop" then
  hl.monitor({ output = "eDP-1", mode = "2256x1504@60",  position = "auto", scale = 1.333 })
  hl.monitor({ output = "DP-4",  mode = "6144x2560@120", position = "0x0",  scale = 1 })

  hl.bind("switch:on:Lid Switch",
    hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable"'),
    { locked = true })
  hl.bind("switch:off:Lid Switch",
    hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, 2256x1504@60, auto, 1.333"'),
    { locked = true })
end

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.config({
  misc = {
    vrr = 1,
  },
})
