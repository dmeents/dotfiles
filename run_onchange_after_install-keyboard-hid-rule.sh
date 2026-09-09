#!/bin/bash
# Give the logged-in user read/write access to the Keychron dongle's hidraw
# nodes so the web configurator (launcher.keychron.com, WebHID) can open it.
#
# Why this is needed: the Keychron Link-KM dongle (3434:d029) exposes five
# hidraw endpoints, and by default the kernel creates every /dev/hidraw* as
# root:root 0600. WebHID runs inside Chrome as the desktop user, so the
# permission prompt appears but every candidate device fails to open -> the
# launcher reports that it cannot find/connect to the dongle. Nothing is wrong
# with the dongle or the RF link; it is purely a device-node ACL problem.
#
# TAG+="uaccess" is the real fix: systemd-logind then attaches an ACL granting
# the user on the active seat access, which is revoked on logout. The
# GROUP/MODE pair is a fallback for the non-logind case (e.g. a headless or
# TTY-only session), and 'users' is a group this account already belongs to.
#
# The rule lives under /etc (root-owned), so this needs sudo; run `chezmoi apply`
# in an interactive shell (same as the package installer). Idempotent;
# run_onchange => re-runs only when the rule text below changes.
set -uo pipefail

RULE_PATH="/etc/udev/rules.d/50-keyboard-hid.rules"
read -r -d '' RULE <<'EOF'
# Grant the active-seat user access to configurable-keyboard HID nodes, so
# WebHID configurators can open them. Managed by chezmoi
# (run_onchange_after_install-keyboard-hid-rule.sh) -- edit there, not here.

# Keychron (3434) -- Link-KM dongle + wired boards, launcher.keychron.com
KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess"
EOF

echo "==> Installing $RULE_PATH (needs sudo)"
printf '%s' "$RULE" | sudo tee "$RULE_PATH" >/dev/null

# Reload + re-fire "add" rules so already-plugged keyboards get the ACL now,
# without waiting for a reboot or a physical re-plug.
if command -v udevadm >/dev/null 2>&1; then
    sudo udevadm control --reload
    sudo udevadm trigger --action=add --subsystem-match=hidraw
    sudo udevadm trigger --action=add --subsystem-match=usb --attr-match=idVendor=3434
    sudo udevadm settle
fi

echo "==> Keyboard HID access rule applied."
echo "    Verify: getfacl -p /dev/hidraw13 | grep dmeents   # expect: user:dmeents:rw-"
