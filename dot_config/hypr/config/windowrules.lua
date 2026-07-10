
-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    move              = "73% 72%",
    size              = "25% 25%",
    pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(Launching\\.{3})$"
    },
    float     = true,
    center    = true,
    workspace = gamingWorkspace,
})
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    size             = "monitor_w monitor_h",
    fullscreen_state = 2,
    content          = "game",
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    float            = true,
    center           = true,
    fullscreen       = false,
    fullscreen_state = 0,
})

-- Apps
local primaryWorkspace = 1

hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, primaryWorkspace, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, primaryWorkspace })
hl.window_rule({ match = { class = "^(.*[Cc]alculator.*)$" }, float = true, size = "380 616" })
hl.window_rule({ match = { class = "^(org.kde.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.ark)$" }, size = "(monitor_w*0.40) (monitor_h*0.40)" })
hl.window_rule({
    match = {
        class = "^(org.kde.dolphin)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    float = true,
    move = {
        "max(0, min(cursor_x - 650, monitor_w - 1320))",
        "max(0, min(cursor_y - 50, monitor_h - 820))"
    },
    size = "1300 800",
})

-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- override opacity in favor of terminal settings for opacity
hl.window_rule({ match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" }, opacity = "1.0 override" })

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

hl.window_rule({ match = { float = true }, move = "50% 50%" })

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

-- Ignore maximize requests from all apps. You'll probably like this.
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃   Personal overrides (not from the spin)                    ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Workspace 2 → master layout, main window right-aligned (ported from the v4
-- config's monitor.lua workspace_rule). The rest of the desktop keeps the spin's
-- dwindle default; only ws2 switches to master, so it always has one big "main"
-- window on the RIGHT with any secondary windows tiling down the left — normal
-- tiling, just one wide primary. `master.mfact` sets the main window's width
-- fraction; the spin only configures dwindle, so setting master here is additive.
-- Uses the v4 value mfact = 0.75 (main window = 75% of the workspace width).
hl.config({ master = { new_status = "master", mfact = 0.75, special_scale_factor = 0.8 } })
hl.workspace_rule({ workspace = "2", layout = "master", layout_opts = { orientation = "right" } })

-- Path of Exile 2 → workspace 2, fake-fullscreen.
-- Ported from the retired v4 config. The spin's Gaming section above routes any
-- steam_app.* to the named "gaming" workspace and fullscreens it; these rules run
-- AFTER it, so they win: PoE lands on numbered workspace 2 instead. `fullscreen_state
-- = "0 2"` = WM leaves the window un-fullscreened (internal 0) while telling the game
-- it IS fullscreen (client 2) — borderless-fullscreen behavior without grabbing the WM.
-- (The old Exiled Exchange 2 / `apt` overlay rules are intentionally dropped — no longer installed.)
hl.window_rule({ name = "tag-poe-title",  tag = "+poe", match = { title = "(Path of Exile 2)" } })
hl.window_rule({ name = "tag-poe-class",  tag = "+poe", match = { class = "(steam_app_2694490)" } })
hl.window_rule({ name = "poe-fullscreen", fullscreen_state = "0 2", match = { tag = "poe" } })
hl.window_rule({ name = "pin-steam-ws2",  workspace = "2 silent", match = { class = "^(steam|Steam)$" } })
hl.window_rule({ name = "pin-poe-ws2",    workspace = "2 silent", match = { tag = "poe" } })
