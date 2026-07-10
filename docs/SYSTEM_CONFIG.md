# System Configuration

This document tracks system-level config that is **not** codified as a
`run_onchange_after_*` script — either because it's interactive/one-time,
non-idempotent, or owned by tooling we shouldn't fight. See "System-level
config: codify vs document" in `CLAUDE.md` for the dividing line. Config that
*is* codified (e.g. the USB keyboard-wake udev rule) lives in a run script, not
here.

## Gaming Performance Optimizations

### CPU Governor — NOT currently applied (verify before acting)

> **Reality check (2026-07-09):** the bespoke `cpupower-performance.service`
> described in earlier versions of this doc **does not exist** on the machine
> (`systemctl is-enabled` → `not-found`), and the live governor is `powersave`,
> not `performance`. The doc was aspirational/stale. Nothing was codified, so
> nothing regressed — but don't assume the performance governor is in effect.

If you do want a persistent performance governor, prefer the **CachyOS-native
path** over a bespoke unit: `cachyos-settings` already ships `cpupower.service`
(currently `disabled`). Set the governor in `/etc/default/cpupower` and enable
that service:

```bash
# /etc/default/cpupower  ->  governor='performance'
sudo systemctl enable --now cpupower.service
```

**Verification:**
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# performance (once cpupower.service is enabled with the governor set)
```

This stays a documented step (not a run script) because it overlaps CachyOS's
own governor management and is a deliberate, occasionally-reversed tuning choice
— exactly the "owned by other tooling / non-routine" case that belongs here.

### Related Hyprland Configuration
Gaming-related environment variables live in the spin-provided Hyprland config at
`~/.config/hypr/config/environment.lua` (supplied by `cachyos-hypr-noctalia`, not tracked
in this repo). Edit it live if you need to change them.

**Note:** `ENABLE_LAYER_MESA_ANTI_LAG` is disabled as it can cause stuttering with recent Mesa drivers on AMD GPUs.
