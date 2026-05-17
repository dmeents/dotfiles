hl.bind("XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl s +5%"),
  { locked = true, repeating = true, description = "Increase screen brightness by 5%" })

hl.bind("XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl s 5%-"),
  { locked = true, repeating = true, description = "Decrease screen brightness by 5%" })
