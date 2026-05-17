hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"),
  { locked = true, description = "Toggle play/pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),
  { locked = true, description = "Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),
  { locked = true, description = "Previous track" })
