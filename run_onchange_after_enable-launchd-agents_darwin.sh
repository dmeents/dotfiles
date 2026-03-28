#!/bin/bash
# Enable macOS LaunchAgents
# This runs after chezmoi applies files, only when this script changes

set -euo pipefail

echo "==> Loading LaunchAgents..."

PLIST="$HOME/Library/LaunchAgents/com.dmeents.logseq-git-sync.plist"
GUI_TARGET="gui/$(id -u)"

if [[ -f "$PLIST" ]]; then
    # Remove existing service first (ignore errors if not loaded)
    launchctl bootout "$GUI_TARGET" "$PLIST" 2>/dev/null || true
    if launchctl bootstrap "$GUI_TARGET" "$PLIST"; then
        echo "  ✓ com.dmeents.logseq-git-sync loaded"
    else
        echo "  ⚠ Could not load com.dmeents.logseq-git-sync"
    fi
else
    echo "  ⚠ $PLIST not found, skipping"
fi

echo "==> LaunchAgents configured!"
