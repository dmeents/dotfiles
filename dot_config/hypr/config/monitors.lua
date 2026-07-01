-- Montior wiki https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output    = "eDP-1",
    mode      = "preferred",
    position  = "auto",
    scale     = 1.175, -- 2256x1504 -> 1920x1280 logical; 1.25 is invalid for this panel
})
