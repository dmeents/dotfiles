#!/bin/bash
# CachyOS Package Installation Script
# This script installs all packages that were manually added after the initial OS setup
# It runs once per machine during chezmoi init/apply
# Note: pacman --needed flag skips already-installed packages

set -e  # Exit on error

echo "==> Installing manually added packages..."

# Base system
base_system=(
    base                 # Base system
    base-devel           # Development tools
    linux-firmware       # Firmware files
)

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
    lsb-release          # LSB version reporting
    memtester            # Memory testing
    mesa-utils           # Mesa utilities
    rebuild-detector     # Detect packages needing rebuild
    which                # Show command paths
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
    hyprshot               # Hyprland screenshot utility
    hyprpicker             # Color picker (optional dep for hyprshot)
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
    rustup                 # Rust toolchain
    nano                   # Simple editor
    nano-syntax-highlighting  # Nano syntax (depends on nano)
    zed                    # Modern editor
    claude-code            # AI code editor
    meld                   # Diff tool
    typescript             # TypeScript compiler
    pnpm                   # Node.js package manager
    ruby                   # Ruby programming language
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
    plymouth              # Boot splash screen
    cachyos-plymouth-bootanimation  # CachyOS Plymouth theme
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
    bind               # DNS server utilities
    dhclient           # DHCP client
    dnsmasq            # Lightweight DNS/DHCP server
    ethtool            # Ethernet settings tool
    inetutils          # Network utilities
    iptables-nft       # Firewall
    iwd                # Wireless daemon
    modemmanager       # Mobile broadband
    networkmanager     # Network management
    networkmanager-openvpn  # OpenVPN plugin
    nss-mdns           # mDNS/Avahi support
    ufw                # Uncomplicated firewall
    wireless-regdb     # Wireless regulatory database
    wpa_supplicant     # WPA supplicant
    xl2tpd             # L2TP daemon
)

# Storage and filesystem
storage=(
    btrfs-assistant          # BTRFS management GUI
    btrfs-progs              # BTRFS utilities
    cachyos-snapper-support  # Snapshot support
    snapper                  # Snapshot manager
    cryptsetup               # Disk encryption
    device-mapper            # Device mapping
    dosfstools               # FAT utilities
    e2fsprogs                # ext2/3/4 utilities
    exfatprogs               # exFAT utilities
    f2fs-tools               # F2FS utilities
    jfsutils                 # JFS utilities
    lvm2                     # Logical volume manager
    mdadm                    # RAID utilities
    nilfs-utils              # NILFS utilities
    xfsprogs                 # XFS utilities
)

# System maintenance
maintenance=(
    bash-completion          # Bash completions
    haveged                  # Entropy daemon
    logrotate                # Log rotation
    man-db                   # Manual pages
    man-pages                # Manual pages content
    os-prober                # OS detection
    pacman-contrib           # Pacman scripts
    perl                     # Perl language
    pkgfile                  # Package file search
    reflector                # Mirror list updater
    s-nail                   # Mail client
    sudo                     # Privilege elevation
    sysfsutils               # sysfs utilities
    texinfo                  # GNU info
)

# Bluetooth
bluetooth=(
    bluez                  # Bluetooth protocol stack
    bluez-hid2hci          # HID to HCI mode switching
    bluez-libs             # Bluetooth libraries
    bluez-utils            # Bluetooth utilities
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

# CachyOS specific tools
cachyos_tools=(
    cachyos-hello              # CachyOS welcome app
    cachyos-hooks              # CachyOS hooks
    cachyos-kernel-manager     # Kernel manager
    cachyos-keyring            # CachyOS keyring
    cachyos-mirrorlist         # Mirror list
    cachyos-packageinstaller   # Package installer
    cachyos-rate-mirrors       # Mirror rating
    cachyos-settings           # CachyOS settings
    cachyos-v3-mirrorlist      # V3 mirrors
    cachyos-v4-mirrorlist      # V4 mirrors
    cachyos-wallpapers         # Wallpapers
    chwd                       # Hardware detection
)

# Applications (official repos)
applications=(
    alacritty             # Terminal emulator
    firefox               # Web browser
    proton-mail-bin       # Email client
    proton-vpn-gtk-app    # Proton VPN
    warp-terminal         # Warp terminal (from warpdotdev repo)
    discord               # Chat app
    solaar                # Logitech manager
    btop                  # Process viewer
    octopi                # Package manager GUI
    kleopatra             # Certificate manager
    ventoy-bin            # Bootable USB creator
    zen-browser-bin       # Privacy browser
)

# Astal libraries (for AGS) - AUR packages, installed later
# These are commented out from official packages and listed in AUR section below
# astal_libs=()

# Graphics (AMD GPU specific)
graphics=(
    lib32-mesa             # 32-bit Mesa
    lib32-opencl-mesa      # 32-bit OpenCL
    lib32-vulkan-radeon    # 32-bit Vulkan
    mesa-utils             # Mesa utilities
    opencl-mesa            # OpenCL support
    rocm-smi-lib           # ROCm monitoring
    vulkan-radeon          # Vulkan driver
    xf86-input-libinput    # Input driver
    xf86-video-amdgpu      # AMD GPU driver
)

# Xorg
xorg=(
    x11-ssh-askpass        # SSH password prompt
    xdg-user-dirs          # User directories
    xorg-server            # X server
    xorg-xdpyinfo          # Display info
    xorg-xinit             # X init
    xorg-xinput            # Input configuration
    xorg-xkill             # Kill X clients
    xorg-xrandr            # Display configuration
    xorg-xwayland          # Xwayland compatibility
)

# AUR Applications (install separately with paru/yay)
aur_applications=(
    # Applications
    beeper-v4-bin         # Chat client
    logseq-desktop        # Note taking
    vicinae-bin           # Tool
    exiled-exchange-2-bin # Game tool
    gitkraken             # Git GUI
    google-chrome         # Chrome browser
    zoom                  # Video conferencing
    
    # AGS and Astal
    aylurs-gtk-shell-git       # AGS widget system
    
    # Astal libraries (for AGS)
    libastal-apps-git          # Apps library
    libastal-battery-git       # Battery library
    libastal-bluetooth-git     # Bluetooth library
    libastal-hyprland-git      # Hyprland library
    libastal-io-git            # IO library
    libastal-mpris-git         # MPRIS library
    libastal-network-git       # Network library
    libastal-notifd-git        # Notification library
    libastal-tray-git          # System tray library
    libastal-wireplumber-git   # Wireplumber library
)

# Python packages
# Note: glances depends on python-defusedxml and python-packaging
python_packages=(
    python                 # Python language
    python-defusedxml      # XML parsing
    python-packaging       # Packaging utilities
    python-pip             # Pip package manager
    python-pipx            # Pipx installer
    python-uv              # UV package manager
)

# Runtime environments
runtimes=(
    aspnet-runtime-8.0     # ASP.NET runtime
    dotnet-runtime-8.0     # .NET runtime
)

# Misc utilities
# Note: steam depends on usbutils
# Note: cachyos-hyprland-settings depends on xorg-xwayland (also pulled by hyprland)
misc=(
    sg3_utils           # SCSI utilities
    lsscsi              # List SCSI devices
    mtools              # MS-DOS tools
    efitools            # EFI tools
    efibootmgr          # EFI boot manager
    hdparm              # HDD parameters
    cachyos-zsh-config  # Zsh config (pulls: vim)
    amd-ucode           # AMD microcode
    dart-sass           # Sass compiler
    diffutils           # Diff utilities
    ex-vi-compat        # Vi compatibility
    less                # Pager
    limine              # Limine bootloader
    limine-snapper-sync # Limine snapshot sync
    paru                # AUR helper
    usb_modeswitch      # USB mode switching
    usbutils            # USB utilities
    watchexec           # File watcher
    yt-dlp              # YouTube downloader
)

# Combine all official repo packages
all_packages=(
    "${base_system[@]}"
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
    "${storage[@]}"
    "${maintenance[@]}"
    "${bluetooth[@]}"
    "${gaming[@]}"
    "${kernel[@]}"
    "${cachyos_tools[@]}"
    "${applications[@]}"
    "${graphics[@]}"
    "${xorg[@]}"
    "${python_packages[@]}"
    "${runtimes[@]}"
    "${misc[@]}"
)

# Install official repo packages
echo "==> Installing ${#all_packages[@]} official packages..."
sudo pacman -S --needed --noconfirm "${all_packages[@]}"

echo "==> Official packages installation complete!"

# Install AUR packages if paru is available
if command -v paru &> /dev/null; then
    if [ ${#aur_applications[@]} -gt 0 ]; then
        echo "==> Installing ${#aur_applications[@]} AUR packages..."
        paru -S --needed --noconfirm "${aur_applications[@]}"
        echo "==> AUR packages installation complete!"
    fi
else
    echo "==> Skipping AUR packages (paru not installed)"
    echo "==> To install AUR packages manually, run:"
    echo "    paru -S ${aur_applications[*]}"
fi

echo "==> All package installation complete!"
