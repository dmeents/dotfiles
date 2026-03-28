#!/bin/bash
# Enable user systemd services
# This runs after chezmoi applies files, only when this script changes

set -euo pipefail

echo "==> Enabling systemd user services..."

# Reload systemd user daemon to pick up new/changed services
systemctl --user daemon-reload

# Enable hyprlock-on-suspend service
if systemctl --user enable hyprlock-on-suspend.service 2>/dev/null; then
    echo "  ✓ hyprlock-on-suspend.service enabled"
else
    echo "  ⚠ Could not enable hyprlock-on-suspend.service (may already be enabled)"
fi

# Enable and start logseq-git-sync timer
if systemctl --user enable --now logseq-git-sync.timer 2>/dev/null; then
    echo "  ✓ logseq-git-sync.timer enabled and started"
else
    echo "  ⚠ Could not enable logseq-git-sync.timer (may already be enabled)"
fi

echo "==> Systemd services configured!"
