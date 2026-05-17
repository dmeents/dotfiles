local machine = require("config.machine")

hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_CURSOR_SIZE", "24")

if machine.type == "desktop" then
  hl.env("PROTON_FSR4_UPGRADE", "1")
  hl.env("PROTON_FSR4_RDNA3_UPGRADE", "1")
  hl.env("PROTON_XESS_UPGRADE", "1")

  hl.env("PROTON_ENABLE_WAYLAND", "1")
  hl.env("PROTON_NO_WM_DECORATION", "1")
  hl.env("PROTON_ENABLE_HDR", "1")

  hl.env("DXVK_ASYNC", "1")
  hl.env("DXVK_STATE_CACHE_PATH", os.getenv("HOME") .. "/.cache/dxvk")

  hl.env("AMD_VULKAN_ICD", "RADV")
  hl.env("RADV_PERFTEST", "gpl,nggc,rt")
  hl.env("VKD3D_CONFIG", "dxr11,dxr")
  hl.env("DXVK_CONFIG_FILE", os.getenv("HOME") .. "/.config/dxvk.conf")

  hl.env("WINE_CPU_TOPOLOGY", "16:8")

  hl.env("WLR_NO_HARDWARE_CURSORS", "1")
  hl.env("WLR_RENDERER_ALLOW_SOFTWARE_CURSORS", "1")
elseif machine.type == "laptop" then
  hl.env("WLR_NO_HARDWARE_CURSORS", "1")
  hl.env("WINE_CPU_TOPOLOGY", "8:4")
end
