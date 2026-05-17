hl.layer_rule({
  name      = "logout-dialog-slide-top",
  animation = "slide top",
  match     = { namespace = "logout_dialog" },
})

hl.layer_rule({
  name      = "waybar-slide-down",
  animation = "slide down",
  match     = { namespace = "waybar" },
})

hl.layer_rule({
  name      = "wallpaper-fade",
  animation = "fade 50%",
  match     = { namespace = "wallpaper" },
})

hl.layer_rule({
  name         = "vicinae-blur",
  blur         = true,
  ignore_alpha = 0,
  no_anim      = true,
  match        = { namespace = "vicinae" },
})
