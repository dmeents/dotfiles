-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    -- Noctalia v5 (beta) with isolated config/state home.
    hl.exec_cmd("env NOCTALIA_CONFIG_HOME=/home/davidm/.config/noctalia-v5 NOCTALIA_STATE_HOME=/home/davidm/.local/state/noctalia-v5 noctalia")
    -- Noctalia v4 fallback: comment the v5 line above and uncomment this to revert.
    -- hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("xhost +SI:localuser:root")
end)
