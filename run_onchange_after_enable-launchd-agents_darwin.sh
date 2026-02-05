#!/bin/bash
# Enable macOS LaunchAgents
# This runs after chezmoi applies files, only when this script changes

set -e

echo "==> Loading LaunchAgents..."

PLIST="$HOME/Library/LaunchAgents/com.dmeents.logseq-git-sync.plist"

if [[ -f "$PLIST" ]]; then
    # Unload first in case it's already loaded (ignore errors)
    launchctl unload "$PLIST" 2>/dev/null || true
    if launchctl load "$PLIST"; then
        echo "  ✓ com.dmeents.logseq-git-sync loaded"
    else
        echo "  ⚠ Could not load com.dmeents.logseq-git-sync"
    fi
else
    echo "  ⚠ $PLIST not found, skipping"
fi

echo "==> LaunchAgents configured!"
