# macOS Setup Guide

This guide explains how to use this chezmoi repository on macOS.

## Quick Start

On a fresh Mac, run:

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

This will:
1. Install Homebrew (if not present)
2. Install all packages via `run_once_before_01-install-packages_darwin.sh`
3. Apply all dotfiles (Linux-specific files are automatically ignored)

## What Gets Installed

### Core Tools
- chezmoi, duf, fastfetch, glances, pv, smartmontools

### Development
- git, gh (GitHub CLI), rustup, nano, zed, meld, go-task, mkcert

### Shell & Terminal
- oh-my-zsh (installed to `~/.oh-my-zsh` on Mac)
- powerlevel10k theme
- zsh plugins: syntax-highlighting, autosuggestions, history-substring-search
- fzf (fuzzy finder)
- nvm (Node version manager)

### File Management
- rsync, wget, unzip

### Network Tools
- openssh, socat, awscli

### Fonts
- JetBrains Mono & Nerd Font variant
- Meslo Nerd Font
- DejaVu, Noto CJK, Noto Color Emoji

### Applications
- Firefox, Warp terminal, Logseq, Zen Browser
- btop (system monitor)
- AeroSpace (window manager)
- aws-vault, Docker

## Platform-Specific Behavior

### Files Ignored on macOS
The `.chezmoiignore` file excludes Linux-specific configs:
- Hyprland, Waybar, wlogout (Wayland/Linux window manager)
- GTK themes
- Octopi, qt5ct, Vicinae
- Solaar (Logitech device manager)
- Systemd services
- Linux-only scripts

### Templated Configs
`.zshrc` is templated to handle platform differences:

**Linux**: System-wide oh-my-zsh (`/usr/share/oh-my-zsh`)
**macOS**: User oh-my-zsh (`~/.oh-my-zsh`)

**Linux aliases**: `pacman` commands (update, cleanup, etc.)
**macOS aliases**: `brew` commands

**Plugin paths**: Adjusted for Homebrew locations (`/opt/homebrew/share/...`)

### macOS-Specific Configs
The following are only applied on macOS:
- AeroSpace window manager config (`.config/aerospace/`)
- SketchyBar config (`.config/sketchybar/`) - if configured

### Shared Configs
These work on both platforms:
- `.p10k.zsh` (Powerlevel10k theme)
- `.bashrc` (if you use bash)
- Zed editor config (`.config/zed/`)
- Warp terminal config (`.config/warp-terminal/`)

## Post-Install Setup

### Xcode Command Line Tools
If not already installed, you may need to accept the Xcode license:
```bash
sudo xcodebuild -license accept
```

### Rust
```bash
rustup-init
```

### Oh-My-Zsh
Oh-My-Zsh needs to be installed manually on macOS:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### NVM (Node.js)
After installation, add to your shell (should be automatic from `.zshrc`):
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
```

Then install Node:
```bash
nvm install --lts
nvm use --lts
```

### AeroSpace (Window Manager)
AeroSpace is installed automatically. To start using it:
1. Launch AeroSpace from Applications
2. Grant accessibility permissions in System Settings
3. Configuration is at `~/.config/aerospace/aerospace.toml`

## Maintenance

### Update All Packages
```bash
brew update && brew upgrade
brew cleanup
```

Or use the alias:
```bash
update
cleanup
```

### Apply Config Changes
Same workflow as Linux:
```bash
chezmoi edit ~/.zshrc   # Edit source
chezmoi diff            # Preview changes
chezmoi apply           # Apply changes
```

### Adding macOS-Specific Packages
Edit `run_once_before_01-install-packages_darwin.sh` and add to the appropriate section:
```bash
brew install <package>        # CLI tools
brew install --cask <app>     # GUI applications
```

## Troubleshooting

### Homebrew Not in PATH
Apple Silicon:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Intel:
```bash
eval "$(/usr/local/bin/brew shellenv)"
```

### Zsh Plugins Not Loading
Ensure plugins are installed:
```bash
brew list | grep zsh
```

Should see: `powerlevel10k`, `zsh-syntax-highlighting`, `zsh-autosuggestions`, `zsh-history-substring-search`

### Oh-My-Zsh Path Issues
Verify `$ZSH` variable:
```bash
echo $ZSH
# Should output: /Users/YOUR_USERNAME/.oh-my-zsh
```

## Template System Reference

### Available Variables
In `.tmpl` files, you can use:
- `.chezmoi.os` - "darwin" on macOS, "linux" on Linux
- `.chezmoi.arch` - "arm64" or "amd64"
- `.chezmoi.hostname` - machine hostname

### Example Template Syntax
```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific config
{{- end }}
```

### File Naming Conventions
- `file_darwin` - Only applied on macOS
- `file_linux` - Only applied on Linux
- `file.tmpl` - Processed as template
- `file` - Applied on all platforms (unless in `.chezmoiignore`)
