#!/bin/bash
# macOS Package Installation Script
# This script installs all packages using Homebrew
# It runs once per machine during chezmoi init/apply
# Note: brew install is idempotent - already installed packages are skipped

set -e  # Exit on error

echo "==> Checking for Homebrew..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH (for Apple Silicon)
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "==> Homebrew already installed"
fi

echo "==> Updating Homebrew..."
brew update

echo "==> Installing packages..."

# Core system utilities
brew install \
    chezmoi \
    duf \
    fastfetch \
    glances \
    pv \
    smartmontools

# Development tools
brew install \
    git \
    gh \
    rustup \
    nano \
    go-task \
    mkcert

# Fonts (via Homebrew Cask)
brew install --cask \
    font-jetbrains-mono \
    font-jetbrains-mono-nerd-font \
    font-meslo-lg-nerd-font \
    font-dejavu \
    font-noto-sans-cjk \
    font-noto-color-emoji

# Terminal & shell
brew install \
    fzf \
    nvm \
    powerlevel10k \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    zsh-history-substring-search

# File management
brew install \
    rsync \
    wget \
    unzip

# Network tools
brew install \
    openssh \
    socat \
    awscli

# Process monitoring
brew install \
    btop

# Applications (Cask)
brew install --cask \
    firefox \
    warp \
    logseq \
    zen \
    zed \
    meld \
    aerospace \
    aws-vault \
    docker

echo "==> Homebrew package installation complete!"
