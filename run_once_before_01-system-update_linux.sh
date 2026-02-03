#!/bin/bash
# System Update and AUR Helper Installation
# This script ensures the system is up-to-date and paru (AUR helper) is installed
# It runs once per machine before installing packages

set -e  # Exit on error

echo "==> Updating system packages..."
sudo pacman -Syu --noconfirm

echo "==> System update complete!"

# Check if paru is installed
if command -v paru &> /dev/null; then
    echo "==> Paru is already installed"
else
    echo "==> Installing paru AUR helper..."
    
    # Install base-devel if not already installed (required for building AUR packages)
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Clone and build paru
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    
    # Cleanup
    cd ~
    rm -rf "$TEMP_DIR"
    
    echo "==> Paru installation complete!"
fi

echo "==> System preparation complete!"
