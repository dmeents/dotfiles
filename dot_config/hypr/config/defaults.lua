-- Hyprland default apps

TERMINAL         = "ghostty"
-- Persistent-session terminal: Ghostty has no session restore on Linux
-- (window-save-state is macOS-only), so Zellij owns the tabs/splits and
-- survives closing the window and rebooting. See ~/.config/zellij/config.kdl.
TERMINAL_SESSION = "ghostty -e zellij attach --create main"
FILE_MANAGER     = "dolphin"
BROWSER          = "zen-browser"
EDITOR           = "gnome-text-editor --new-window"
CALCULATOR       = "gnome-calculator"
