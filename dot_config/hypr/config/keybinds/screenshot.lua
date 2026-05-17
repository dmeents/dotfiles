hl.bind("Print",
  hl.dsp.exec_cmd("hyprshot -m region"),
  { description = "Screenshot region (save + clipboard)" })

hl.bind("SHIFT + Print",
  hl.dsp.exec_cmd("hyprshot -m window"),
  { description = "Screenshot full window (save + clipboard)" })

hl.bind("CTRL + Print",
  hl.dsp.exec_cmd("hyprshot -m output"),
  { description = "Screenshot full screen (save + clipboard)" })

hl.bind("ALT + Print",
  hl.dsp.exec_cmd("hyprshot -m active"),
  { description = "Screenshot active monitor (save + clipboard)" })
