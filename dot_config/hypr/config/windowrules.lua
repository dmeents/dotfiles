local colors = require("config.colors")

-- Float necessary windows
hl.window_rule({ name = "float-pavucontrol",   float = true, match = { class = "^(org.pulseaudio.pavucontrol)$" } })
hl.window_rule({ name = "float-pip-empty",     float = true, match = { class = "^()$", title = "^(Picture in picture)$" } })
hl.window_rule({ name = "float-save-file",     float = true, match = { class = "^()$", title = "^(Save File)$" } })
hl.window_rule({ name = "float-open-file",     float = true, match = { class = "^()$", title = "^(Open File)$" } })
hl.window_rule({ name = "float-librewolf-pip", float = true, match = { class = "^(LibreWolf)$", title = "^(Picture-in-Picture)$" } })
hl.window_rule({ name = "float-blueman",       float = true, match = { class = "^(blueman-manager)$" } })
hl.window_rule({ name = "float-xdg-portal",    float = true, match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$" } })
hl.window_rule({ name = "float-polkit",        float = true, match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$" } })
hl.window_rule({ name = "float-cachyos-hello", float = true, match = { class = "^(CachyOSHello)$" } })
hl.window_rule({ name = "float-zenity",        float = true, match = { class = "^(zenity)$" } })
hl.window_rule({ name = "float-steam-updater", float = true, match = { class = "^()$", title = "^(Steam - Self Updater)$" } })

-- Opacity overrides
hl.window_rule({ name = "opacity-file-managers",  opacity = 0.92, match = { class = "^(thunar|nemo)$" } })
hl.window_rule({ name = "opacity-discord-clones", opacity = 0.96, match = { class = "^(discord|armcord|webcord)$" } })
hl.window_rule({ name = "opacity-qq-telegram",    opacity = 0.95, match = { title = "^(QQ|Telegram)$" } })
hl.window_rule({ name = "opacity-netease-music",  opacity = 0.95, match = { title = "^(NetEase Cloud Music Gtk4)$" } })

-- General floating-window placement and decorations
hl.window_rule({
  name  = "float-pip-sized",
  float = true,
  size  = { 960, 540 },
  move  = "(monitor_w-w)/2 (monitor_h-h)/2",
  match = { title = "^(Picture-in-Picture)$" },
})
hl.window_rule({
  name  = "float-media-tools",
  float = true,
  move  = "(monitor_w-w)/2 (monitor_h-h)/2",
  size  = { 960, 540 },
  match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" },
})
hl.window_rule({ name = "pin-danmufloat",     pin = true,     match = { title = "^(danmufloat)$" } })
hl.window_rule({ name = "round-danmu-term",   rounding = 5,   match = { title = "^(danmufloat|termfloat)$" } })
hl.window_rule({ name = "anim-term-slide-r",  animation = "slide right", match = { class = "^(kitty|Alacritty)$" } })
hl.window_rule({ name = "no-blur-firefox",    no_blur = true, match = { class = "^(org.mozilla.firefox)$" } })

-- Floating-window border/rounding on workspaces 1-10
hl.window_rule({
  name         = "deco-floats-w1-10",
  border_size  = 2,
  border_color = colors.cachylblue,
  rounding     = 8,
  match        = { float = true, workspace = "w[fv1-10]" },
})

-- Tiling-window border/rounding on workspaces 1-10
hl.window_rule({
  name        = "deco-tiles-w1-10",
  border_size = 3,
  rounding    = 4,
  match       = { float = false, workspace = "f[1-10]" },
})

-- Workspace gaps
hl.workspace_rule({ workspace = "w[tv1-10]", gaps_out = 5, gaps_in = 3 })
hl.workspace_rule({ workspace = "f[1]",      gaps_out = 5, gaps_in = 3 })

-- POE2 tag + fullscreen-mode rules
hl.window_rule({ name = "tag-poe-title", tag = "+poe", match = { title = "(Path of Exile 2)" } })
hl.window_rule({ name = "tag-poe-class", tag = "+poe", match = { class = "(steam_app_2694490)" } })
hl.window_rule({ name = "poe-fullscreen", fullscreen_state = "0 2", match = { tag = "poe" } })

-- Workspace pinning
hl.window_rule({ name = "pin-steam-ws2",    workspace = "2 silent", match = { class = "^(steam|Steam)$" } })
hl.window_rule({ name = "pin-poe-ws2",      workspace = "2 silent", match = { tag = "poe" } })
