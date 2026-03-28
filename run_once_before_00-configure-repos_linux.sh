#!/bin/bash
# Configure custom package repositories
# This script runs once per machine during chezmoi init/apply
# It must run before package installation

set -euo pipefail

echo "==> Configuring custom repositories..."

# Add warpdotdev repository for warp-terminal
if ! grep -q "\[warpdotdev\]" /etc/pacman.conf; then
    echo "==> Adding warpdotdev repository..."
    sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[warpdotdev]
SigLevel = Optional TrustAll
Server = https://releases.warp.dev/linux/pacman/$repo/$arch
EOF
    echo "==> warpdotdev repository added"
else
    echo "==> warpdotdev repository already configured"
fi

# Update package database
echo "==> Updating package database..."
sudo pacman -Sy

echo "==> Repository configuration complete!"
