local defaults = require("config.defaults")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.on("hyprland.start", function()
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

  hl.exec_cmd("vicinae server")
  hl.exec_cmd(defaults.idleHandler)
  hl.exec_cmd(defaults.wallpapers)

  hl.exec_cmd("ags run ~/.config/slate-panel/app.ts")
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("mako")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("solaar --window=hide")
  hl.exec_cmd([[bash -c "mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob & disown"]])
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

  hl.exec_cmd("systemctl --user import-environment")
  hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null")
  hl.exec_cmd("dbus-update-activation-environment --systemd")
end)
