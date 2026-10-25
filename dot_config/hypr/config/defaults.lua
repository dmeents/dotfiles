-- Hyprland default apps

-- Ghostty's config sets `command` to attach the persistent Zellij session, so
-- TERMINAL already opens it. See ~/.config/ghostty/config.
TERMINAL         = "ghostty"
-- Escape hatch: `-e` overrides that command, giving a plain shell outside Zellij.
TERMINAL_PLAIN   = "ghostty -e fish"
FILE_MANAGER     = "dolphin"
BROWSER          = "zen-browser"
EDITOR           = "gnome-text-editor --new-window"
CALCULATOR       = "gnome-calculator"
