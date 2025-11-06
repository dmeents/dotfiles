# System Configuration

This document tracks system-level configurations that require root privileges and cannot be managed directly by chezmoi.

## Gaming Performance Optimizations

### CPU Governor Service
**Location:** `/etc/systemd/system/cpupower-performance.service`

Sets the CPU governor to `performance` mode to prevent stuttering in games caused by CPU frequency scaling delays.

**Service content:**
```ini
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > $gov; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**Installation:**
```bash
sudo systemctl enable cpupower-performance.service
sudo systemctl start cpupower-performance.service
```

**Verification:**
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Should output: performance
```

### Related Hyprland Configuration
See `.config/hypr/config/environment.conf` for gaming-related environment variables.

**Note:** `ENABLE_LAYER_MESA_ANTI_LAG` is disabled as it can cause stuttering with recent Mesa drivers on AMD GPUs.
