#!/bin/bash
# Arm USB remote-wakeup on the USB4206 hub chain so the keyboard can wake the
# machine from S3 (deep) sleep.
#
# Why this is needed: the KBD8x keyboard sits behind two Microchip USB4206 hubs
# (0424:4206) and a root hub. USB remote-wakeup only propagates if EVERY device
# in the path from the keyboard up to the xHCI controller is armed for wakeup.
# The keyboard and the xHCI controller are armed by default, but the two USB4206
# hubs enumerate with power/wakeup=disabled, so the keypress resume signal dies
# at the first hub and never reaches the controller -> pressing a key doesn't
# wake the box. The udev rule arms every 0424:4206 hub at enumeration time.
#
# We deliberately match idProduct 4206 (the peripheral hubs) and NOT the sibling
# USB7206 hub (0424:7206), which carries the 2.5G LAN -- arming that one would
# also enable wake-on-LAN relay and risk spurious network wakeups.
#
# The rule lives under /etc (root-owned), so this needs sudo; run `chezmoi apply`
# in an interactive shell (same as the package installer). Idempotent;
# run_onchange => re-runs only when the rule text below changes.
set -uo pipefail

RULE_PATH="/etc/udev/rules.d/50-usb-keyboard-wake.rules"
read -r -d '' RULE <<'EOF'
# Arm USB remote-wakeup on the USB4206 peripheral-hub chain (0424:4206) so a
# keypress can wake the system from deep sleep. Managed by chezmoi
# (run_onchange_after_install-usb-wake-rule.sh) -- edit there, not here.
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0424", ATTR{idProduct}=="4206", ATTR{power/wakeup}="enabled"
EOF

echo "==> Installing $RULE_PATH (needs sudo)"
printf '%s' "$RULE" | sudo tee "$RULE_PATH" >/dev/null

# Reload + re-fire "add" rules so already-enumerated hubs get armed now, without
# waiting for a reboot or a physical re-plug.
if command -v udevadm >/dev/null 2>&1; then
    sudo udevadm control --reload
    sudo udevadm trigger --action=add --subsystem-match=usb \
        --attr-match=idVendor=0424 --attr-match=idProduct=4206
fi

echo "==> USB keyboard wake rule applied."
echo "    Verify: cat /sys/bus/usb/devices/3-2/power/wakeup   # expect: enabled"
