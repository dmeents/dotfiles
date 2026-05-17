local machine = require("config.machine")

hl.config({
  input = {
    follow_mouse                = 2,
    float_switch_override_focus = 2,
    scroll_factor               = 1.0,
    scroll_method               = "2fg",
    numlock_by_default          = true,
    repeat_rate                 = 50,
    repeat_delay                = 300,
    sensitivity                 = machine.type == "laptop" and 0.5 or 1,
    force_no_accel              = machine.type ~= "laptop",

    touchpad = {
      natural_scroll          = false,
      tap_to_click            = true,
      drag_lock               = true,
      disable_while_typing    = true,
      clickfinger_behavior    = true,
      middle_button_emulation = false,
    },
  },

  cursor = {
    no_hardware_cursors = true,
  },
})
