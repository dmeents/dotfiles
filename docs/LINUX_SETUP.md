# Linux (CachyOS) Setup Guide

This guide explains how to use this chezmoi repository on Linux, specifically CachyOS with Hyprland.

## Quick Start

On a fresh CachyOS installation, run:

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

This will:
1. Update system packages with `pacman -Syu`
2. Install paru (AUR helper) if needed
3. Install all packages via `run_once_before_01-install-packages_linux.sh`
4. Apply all dotfiles (macOS-specific files are automatically ignored)

## What Gets Installed

### Core System Utilities
- chezmoi, cpupower, dmidecode, dmraid, duf, fastfetch
- fsarchiver, glances, hwdetect, hwinfo, plocate, pv, smartmontools

### Hyprland Desktop Environment
- **cachyos-hyprland-settings** (meta package that pulls in):
  - Hyprland compositor
  - Waybar, mako, wofi, wlogout, wob
  - xdg-desktop-portal-hyprland
  - grimblast-git, slurp, swaybg, swaylock variants
  - wl-clipboard, bemenu
- hypridle, hyprlock, hyprpaper, uwsm
- rofi & rofi-emoji
- xdg-desktop-portal-xapp

### Wayland Utilities
- hyprshot, hyprpicker, swappy

### Audio/Video (PipeWire)
- pipewire-alsa, pipewire-pulse, wireplumber
- pavucontrol, alsa-utils, alsa-firmware, sof-firmware
- GStreamer plugins (libav, pipewire, bad, ugly)
- VLC plugins, ffmpegthumbnailer, libdvdcss

### Development Tools
- git, github-cli, rustup, vi, nano, zed, meld

### Fonts
- Adobe Source Han (CJK)
- Noto fonts (CJK, emoji)
- JetBrains Mono & Nerd Font
- Meslo Nerd Font
- DejaVu, Bitstream Vera, OpenSans

### Theming
- **cachyos-nord-gtk-theme-git** (via cachyos-hyprland-settings)
- kvantum-theme-nordic-git
- Capitaine cursors

### System Services
- accountsservice, gnome-keyring, power-profiles-daemon
- rtkit

### File Management
- nemo, rsync, unrar, unzip, wget
- libgsf, libopenraw, poppler-glib, webkit2gtk-4.1

### Network Tools
- openssh, nfs-utils, ntp, socat

### Gaming
- **cachyos-gaming-meta** (pulls Steam dependencies)
- steam

### Kernels
- linux-cachyos & linux-cachyos-headers
- linux-cachyos-lts & linux-cachyos-lts-headers
- limine-mkinitcpio-hook

### Applications
- firefox, proton-mail-bin, warp-terminal, solaar, btop, octopi

### AUR Applications
- beeper-v4-bin, zen-browser-bin, logseq-desktop
- vicinae-bin, exiled-exchange-2-bin, gitkraken

## Platform-Specific Behavior

### Files Ignored on Linux
The `.chezmoiignore` file excludes macOS-specific configs:
- macOS-only scripts (`*_darwin.sh`)

### Templated Configs
`.zshrc` is templated to handle platform differences:

**Linux**: 
- System-wide oh-my-zsh (`/usr/share/oh-my-zsh`)
- pacman aliases (update, cleanup, fixpacman, etc.)
- Plugin paths: `/usr/share/zsh/plugins/...`
- pkgfile "command not found" handler
- nvm from `/usr/share/nvm/init-nvm.sh`

### Linux-Only Configs
These are exclusive to Linux (ignored on macOS):
- **Hyprland**: `.config/hypr/` - Window manager configuration
- **Waybar**: `.config/waybar/` - Status bar
- **wlogout**: `.config/wlogout/` - Logout menu
- **GTK**: `.config/gtk-3.0/`, `.config/gtk-4.0/` - Theme settings
- **Solaar**: `.config/solaar/` - Logitech device manager
- **XDG portals**: `.config/xdg-desktop-portal/`

## Post-Install Setup

### Initialize Rust
```bash
rustup default stable
```

### Enable Services
```bash
# Power management
sudo systemctl enable power-profiles-daemon
```

### Hyprland First Launch
On first login to Hyprland:
1. Waybar should auto-start (configured in `hypr/config/autostart.conf`)
2. Wallpaper will load via hyprpaper
3. Idle daemon (hypridle) will start for screen locking

### CPU Performance (Gaming)
See `SYSTEM_CONFIG.md` for CPU governor service setup for gaming performance.

## Maintenance

### System Updates
```bash
sudo pacman -Syu      # Update official packages
paru -Syu             # Update AUR packages
```

Or use the aliases:
```bash
update                # Runs: sudo pacman -Syu
```

### Clean Package Cache
```bash
sudo pacman -Scc      # Clean package cache
sudo pacman -Rsn $(pacman -Qtdq)  # Remove orphaned packages
```

Or use the aliases:
```bash
cleanch               # Clean cache
cleanup               # Remove orphans
```

### Apply Config Changes
```bash
chezmoi edit ~/.config/hypr/hyprland.conf   # Edit source
chezmoi diff                                # Preview changes
chezmoi apply                               # Apply changes
hyprctl reload                              # Reload Hyprland
```

### Adding New Packages

To persist a new package across machines:

1. Check if it's a dependency:
   ```bash
   pacman -Qi <package> | grep "Install Reason"
   ```

2. If "Explicitly installed", add to `run_once_before_01-install-packages_linux.sh`

3. Find recently installed explicit packages not in the script:
   ```bash
   comm -23 <(pacman -Qe | awk '{print $1}' | sort) \
            <(grep -oP '(?<=\s{4})\S+(?=\s+#)' run_once_before_01-install-packages_linux.sh | sort) \
            | head -20
   ```

## Hyprland Configuration

### Config Structure
Modular configuration in `.config/hypr/`:
- `hyprland.conf` - Main config (sources all modules)
- `config/animations.conf` - Animation settings
- `config/autostart.conf` - Auto-start applications
- `config/decorations.conf` - Window decorations
- `config/environment.conf` - Environment variables
- `config/input.conf` - Input device settings
- `config/keybinds.conf` - Keyboard shortcuts
- `config/monitor.conf` - Monitor configuration
- `config/variables.conf` - General variables
- `config/windowrules.conf` - Window rules

### Reload Config
```bash
hyprctl reload
```

Or use the keybind: `SUPER + SHIFT + R`

### Testing Changes
```bash
# Preview what would change
chezmoi diff

# Apply without committing
chezmoi apply

# Test in Hyprland
hyprctl reload
```

## Shell Environment

### Zsh Setup
- **Framework**: oh-my-zsh (system-wide installation)
- **Theme**: Powerlevel10k
- **Plugins**: git, fzf, extract, syntax-highlighting, autosuggestions, history-substring-search

### Useful Aliases (from .zshrc)
```bash
# System updates
update          # sudo pacman -Syu
rmpkg <pkg>     # Remove package
cleanch         # Clean package cache
cleanup         # Remove orphaned packages
fixpacman       # Fix pacman lock file

# Build tools
make            # Parallel make with all cores
ninja           # Parallel ninja with all cores
n               # Alias for ninja

# System monitoring
jctl            # Journal errors
rip             # Recent installed packages
glances         # System monitor
btop            # Process viewer

# Misc
c               # clear
tb              # Pipe to termbin (nc termbin.com 9999)
```

## Troubleshooting

### Hyprland Won't Start
Check logs:
```bash
journalctl --user -u hyprland -b
cat ~/.cache/hyprland/hyprland.log
```

### Waybar Not Showing
Restart Waybar:
```bash
pkill waybar && waybar &
```

### Audio Not Working
Check PipeWire status:
```bash
systemctl --user status pipewire pipewire-pulse wireplumber
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Pacman Lock File
```bash
fixpacman       # Alias for: sudo rm /var/lib/pacman/db.lck
```

### AUR Helper (paru) Issues
Reinstall paru:
```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

## Hardware-Specific Notes

### AMD Ryzen 9 7950X3D
- CPU governor service available (see `SYSTEM_CONFIG.md`)
- Gaming performance optimizations in `hypr/config/environment.conf`

### AMD Radeon RX 7900 XT
- MESA drivers installed via cachyos-gaming-meta
- Anti-lag disabled due to stuttering issues

### High RAM Systems (128GB)
- XMP profile may cause instability
- Current config: base clock speeds for stability

## Template System Reference

### Available Variables
In `.tmpl` files:
- `.chezmoi.os` - "linux" on Linux, "darwin" on macOS
- `.chezmoi.arch` - "amd64", "arm64", etc.
- `.chezmoi.hostname` - machine hostname

### File Naming Conventions
- `file_linux` - Only applied on Linux
- `file_darwin` - Only applied on macOS
- `file.tmpl` - Processed as template
- `file` - Applied on all platforms (unless in `.chezmoiignore`)
