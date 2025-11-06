# Dotfiles

Multi-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/), supporting both Linux (CachyOS/Hyprland) and macOS (Homebrew).

## 🚀 Quick Start

### Linux (CachyOS)
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

### macOS
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

## 📋 What's Included

### Cross-Platform
- **Shell**: Zsh with oh-my-zsh, Powerlevel10k theme
- **Editors**: Zed, Nano
- **Terminal**: Warp terminal configuration
- **Development**: Git, GitHub CLI, Rust toolchain
- **Utilities**: fzf, btop, glances, and more

### Linux-Specific (CachyOS/Hyprland)
- **Window Manager**: Hyprland with modular configuration
- **Status Bar**: Waybar with custom modules
- **Desktop**: wlogout, rofi, hyprlock, hypridle
- **Theming**: GTK themes, Kvantum, Nordic theme
- **Package Manager**: pacman/paru with helpful aliases

### macOS-Specific
- **Package Manager**: Homebrew with automated installation
- **Native Apps**: Firefox, Logseq, Zen Browser

## 🗂️ Repository Structure

```
.
├── README.md                                    # This file
├── WARP.md                                      # Warp AI assistant context
├── docs/
│   ├── LINUX_SETUP.md                          # Detailed Linux guide
│   ├── MACOS_SETUP.md                          # Detailed macOS guide
│   └── SYSTEM_CONFIG.md                        # System-level configurations
├── .chezmoiignore                               # Platform-specific ignore rules
├── dot_config/                                  # ~/.config/ directory
│   ├── hypr/                                   # Hyprland (Linux only)
│   ├── waybar/                                 # Waybar (Linux only)
│   ├── zed/                                    # Zed editor (cross-platform)
│   ├── warp-terminal/                          # Warp terminal (cross-platform)
│   └── ...
├── dot_zshrc.tmpl                              # Templated Zsh config
├── dot_p10k.zsh                                # Powerlevel10k theme
├── dot_bashrc                                  # Bash config
├── run_once_before_00-system-update_linux.sh   # Linux system update
├── run_once_before_01-install-packages_linux.sh # Linux package installation
└── run_once_before_01-install-packages_darwin.sh # macOS package installation
```

## 🔧 Platform Support

This repository uses chezmoi's templating system to manage configurations for multiple platforms:

- **`.chezmoiignore`**: Excludes platform-specific files automatically
- **OS suffixes**: `_linux` and `_darwin` for platform-specific scripts
- **Templates**: `.tmpl` files with conditional logic for cross-platform configs

### How It Works

**On Linux**: You get Hyprland, Waybar, GTK themes, and pacman-based tooling

**On macOS**: You get Homebrew packages, native macOS apps, and Mac-specific paths

**Both platforms**: Share zsh config, editor settings, and development tools

## 📚 Documentation

- **[Linux Setup Guide](docs/LINUX_SETUP.md)** - Complete guide for CachyOS/Hyprland setup
- **[macOS Setup Guide](docs/MACOS_SETUP.md)** - Complete guide for macOS setup
- **[System Configuration](docs/SYSTEM_CONFIG.md)** - System-level configs requiring root
- **[WARP.md](WARP.md)** - Context file for Warp AI assistant

## 🛠️ Common Commands

```bash
# View what would change
chezmoi diff

# Apply changes
chezmoi apply

# Edit a file (automatically edits source)
chezmoi edit ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.config/newapp/config.conf

# Update from repository
chezmoi update

# Check status
chezmoi status
```

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own use!

## 📄 License

MIT
