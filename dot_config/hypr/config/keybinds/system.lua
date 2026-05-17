local defaults  = require("config.defaults")
local variables = require("config.keybinds.variables")
local mod       = variables.mainMod

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(defaults.terminal),
  { description = "Opens your preferred terminal emulator (" .. defaults.terminal .. ")" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd(defaults.fileManager),
  { description = "Opens your preferred file manager (" .. defaults.fileManager .. ")" })
hl.bind(mod .. " + Q", hl.dsp.window.close(),
  { description = "Closes (not kill) current window" })
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("uwsm stop"),
  { description = "Exits Hyprland by terminating the user session" })
hl.bind(mod .. " + SHIFT + ALT + Escape", hl.dsp.exec_cmd("hyprctl dispatch exit"),
  { description = "Emergency exit Hyprland" })
hl.bind(mod .. " + SHIFT + escape", hl.dsp.exec_cmd("hyprctl dispatch resizewindowpixel exact 100% 100%"),
  { description = "Reset window size to tile" })
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("vicinae toggle"),
  { description = "Toggle " .. defaults.appLauncher })
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }),
  { description = "Toggles current window fullscreen mode" })
hl.bind(mod .. " + Y", hl.dsp.window.pin(),
  { description = "Pin current window (shows on all workspaces)" })
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"),
  { description = "Toggles current window split mode" })
hl.bind(mod .. " + L", hl.dsp.exec_cmd(defaults.lock),
  { description = "Lock the screen" })
hl.bind(mod .. " + O", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"),
  { description = "Reload/restart Waybar" })
hl.bind(mod .. " + K", hl.dsp.group.toggle(),
  { description = "Toggle current window group mode" })
hl.bind(mod .. " + Tab", hl.dsp.group.next(),
  { description = "Switch to the next window in the group" })
