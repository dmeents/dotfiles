local colors = require("config.colors")

hl.config({
  general = {
    gaps_in     = 3,
    gaps_out    = 5,
    border_size = 3,
    layout      = "dwindle",

    col = {
      active_border   = colors.cachylgreen,
      inactive_border = colors.cachymblue,
    },

    snap = {
      enabled = true,
    },
  },

  group = {
    col = {
      border_active          = colors.cachydgreen,
      border_inactive        = colors.cachylgreen,
      border_locked_active   = colors.cachymgreen,
      border_locked_inactive = colors.cachydblue,
    },

    groupbar = {
      font_family = "Fira Sans",
      text_color  = colors.cachydblue,
      col = {
        active          = colors.cachydgreen,
        inactive        = colors.cachylgreen,
        locked_active   = colors.cachymgreen,
        locked_inactive = colors.cachydblue,
      },
    },
  },

  misc = {
    font_family             = "Fira Sans",
    splash_font_family      = "Fira Sans",
    disable_hyprland_logo   = true,
    background_color        = colors.cachydblue,
    enable_swallow          = true,
    swallow_regex           = "^(nautilus|nemo|thunar|btrfs-assistant.)$",
    swallow_exception_regex = "^(warp|dev\\.warp\\.Warp)$",
    focus_on_activate       = true,
    vrr                     = 2,

    col = {
      splash = colors.cachylgreen,
    },
  },

  render = {
    direct_scanout = true,
  },

  animations = {
    enabled = true,
  },
})
