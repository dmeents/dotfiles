#!/bin/bash
# CachyOS Package Installation Script
# This script installs all packages that were manually added after the initial OS setup
# It runs once per machine during chezmoi init/apply

set -e  # Exit on error

echo "==> Installing manually added packages..."

# Core system utilities
system_utils=(
    chezmoi              # Dotfile manager
    cpupower             # CPU frequency utilities
    dmidecode            # DMI table decoder
    dmraid               # RAID utilities
    duf                  # Modern disk usage utility
    fastfetch            # System info tool
    fsarchiver           # Filesystem archiver
    glances              # System monitor
    hwdetect             # Hardware detection
    hwinfo               # Hardware info
    plocate              # Fast file locator
    pv                   # Pipe viewer for monitoring data
    smartmontools        # HDD/SSD health monitoring
)

# Hyprland and Wayland essentials
# Note: cachyos-hyprland-settings pulls in most of the Hyprland ecosystem as dependencies
hyprland_packages=(
    cachyos-hyprland-settings    # CachyOS Hyprland configs (pulls: hyprland, waybar, mako, wofi, wlogout, wob, xdg-desktop-portal-hyprland, and more)
    hypridle                     # Idle daemon
    hyprlock                     # Screen locker
    hyprpaper                    # Wallpaper manager
    uwsm                         # Window manager session manager
    rofi                         # Application launcher
    rofi-emoji                   # Emoji picker (depends on rofi)
    xdg-desktop-portal-xapp      # Additional portal
)

# Wayland utilities
# Note: cachyos-hyprland-settings already pulls in: grimblast-git, slurp, swaybg, swaylock-effects-git, swaylock-fancy-git, wl-clipboard, bemenu, bemenu-wayland
wayland_utils=(
    swappy                 # Screenshot editor
)

# Audio/Video
# Note: cachyos-gaming-meta pulls in alsa-plugins
media_packages=(
    pipewire-alsa          # ALSA support
    pipewire-pulse         # PulseAudio replacement
    wireplumber            # Session manager
    pavucontrol            # Volume control GUI (pamixer pulled by cachyos-hyprland-settings)
    gst-libav              # GStreamer plugin
    gst-plugin-pipewire    # PipeWire plugin
    gst-plugins-bad        # Additional codecs
    gst-plugins-ugly       # Restricted codecs
    vlc-plugins-all        # VLC plugins
    ffmpegthumbnailer      # Video thumbnails
    libdvdcss              # DVD decryption
    alsa-firmware          # ALSA firmware
    alsa-utils             # ALSA utilities
    sof-firmware           # Sound firmware
)

# Development tools
# Note: cachyos-zsh-config pulls in vim, hwdetect pulls in ripgrep
dev_tools=(
    git                    # Version control
    github-cli             # GitHub CLI
    gitkraken              # Git GUI
    rustup                 # Rust toolchain
    vi                     # Basic editor
    nano                   # Simple editor
    nano-syntax-highlighting  # Nano syntax (depends on nano)
    zed                    # Modern editor
    meld                   # Diff tool
)

# Fonts
# Note: cachyos-hyprland-settings pulls in: awesome-terminal-fonts, noto-fonts, noto-fonts-emoji
# Note: cachyos-gaming-meta pulls in: ttf-liberation
fonts=(
    adobe-source-han-sans-cn-fonts  # Chinese fonts
    adobe-source-han-sans-jp-fonts  # Japanese fonts
    adobe-source-han-sans-kr-fonts  # Korean fonts
    noto-color-emoji-fontconfig     # Emoji config (depends on noto-fonts-emoji)
    noto-fonts-cjk                  # CJK fonts
    opendesktop-fonts               # Desktop fonts
    ttf-bitstream-vera              # Vera fonts
    ttf-dejavu                      # DejaVu fonts
    ttf-jetbrains-mono              # JetBrains Mono
    ttf-jetbrains-mono-nerd         # JetBrains Nerd
    ttf-meslo-nerd                  # Meslo Nerd
    ttf-opensans                    # Open Sans
)

# Theming
# Note: cachyos-hyprland-settings pulls in: cachyos-nord-gtk-theme-git, kvantum, qt5ct, capitaine-cursors, polkit-kde-agent
# Note: kvantum-theme-nordic-git depends on kvantum
theming=(
    kvantum-theme-nordic-git    # Nordic theme (depends on kvantum)
)

# System services
# Note: waybar (from cachyos-hyprland-settings) depends on upower
# Note: power-profiles-daemon depends on upower
services=(
    accountsservice        # User account info
    gnome-keyring         # Credential storage
    power-profiles-daemon # Power management (depends on upower)
    rtkit                 # Real-time kit
    sddm                  # Display manager
)

# File management
file_tools=(
    nemo               # File manager
    rsync              # File sync
    unrar              # RAR extraction
    unzip              # ZIP extraction
    wget               # Downloader
    libgsf             # Structured file library
    libopenraw         # RAW image support
    poppler-glib       # PDF rendering
    webkit2gtk-4.1     # Web rendering
    fuse2              # FUSE support
)

# Network tools
network=(
    openssh            # SSH client/server
    nfs-utils          # NFS utilities
    ntp                # Time sync
    socat              # Socket utility
)

# System maintenance
maintenance=(
    cachyos-snapper-support  # Snapshot support
    bash-completion          # Bash completions
    haveged                  # Entropy daemon
    xfsprogs                 # XFS utilities
)

# Gaming (from cachyos-gaming-meta and extras)
# Note: steam depends on xdg-user-dirs, usbutils
gaming=(
    cachyos-gaming-meta    # Gaming meta package (pulls: alsa-plugins, ttf-liberation)
    steam                  # Steam client
)

# Kernel
# Note: *-headers packages depend on the base kernel package
kernel=(
    linux-cachyos          # Main kernel
    linux-cachyos-headers  # Kernel headers (depends on linux-cachyos)
    linux-cachyos-lts      # LTS kernel
    linux-cachyos-lts-headers  # LTS headers (depends on linux-cachyos-lts)
    limine-mkinitcpio-hook # Hook (depends on limine)
)

# Applications
applications=(
    beeper-v4-bin         # Chat client
    firefox               # Web browser
    zen-browser-bin       # Privacy browser
    logseq-desktop        # Note taking
    proton-mail-bin       # Email client
    vicinae-bin           # Tool
    warp-terminal         # Terminal
    exiled-exchange-2-bin # Game tool
    solaar                # Logitech manager
    btop                  # Process viewer
    octopi                # Package manager GUI
)

# Python packages
# Note: glances depends on python-defusedxml and python-packaging
python_packages=()

# Misc utilities
# Note: steam depends on usbutils
# Note: cachyos-hyprland-settings depends on xorg-xwayland (also pulled by hyprland)
misc=(
    sg3_utils           # SCSI utilities
    lsscsi              # List SCSI devices
    mtools              # MS-DOS tools
    efitools            # EFI tools
    hdparm              # HDD parameters
    nilfs-utils         # NILFS utilities
    cachyos-zsh-config  # Zsh config (pulls: vim)
    amd-ucode           # AMD microcode
)

# Combine all packages
all_packages=(
    "${system_utils[@]}"
    "${hyprland_packages[@]}"
    "${wayland_utils[@]}"
    "${media_packages[@]}"
    "${dev_tools[@]}"
    "${fonts[@]}"
    "${theming[@]}"
    "${services[@]}"
    "${file_tools[@]}"
    "${network[@]}"
    "${maintenance[@]}"
    "${gaming[@]}"
    "${kernel[@]}"
    "${applications[@]}"
    "${python_packages[@]}"
    "${misc[@]}"
)

# Install packages
echo "==> Installing ${#all_packages[@]} packages..."
sudo pacman -S --needed --noconfirm "${all_packages[@]}"

echo "==> Package installation complete!"
echo "==> Note: AUR packages (if any) need to be installed separately with paru/yay"
