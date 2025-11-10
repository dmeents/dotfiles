# System Information

<!-- You should change the system information below to match your own -->

## System Configurations

This set of rules is for general use on many machines. You will find multiple configurations for different platforms that this repository provides.

**Linux Desktop (Personal PC)**

- **CPU**: AMD Ryzen 7 9550x3D (16) @ 4.3GHz, 5.7GHz boos
- **RAM**: 128.0GiB
- **GPU**: AMD Radeon RX 7900 XT
- **Storage**: 4TB SSD
- **Distribution**: CachyOS Linux (Arch-based)
- **Window Manager**: Hyprland (Wayland compositor)
- **Shell**: zsh with oh-my-zsh and Powerlevel10k
- **Package Manager**: pacman/paru (AUR)

**MacBook Pro (Work Laptop)**

- **CPU**: Apple M3 Max
- **RAM**: 48.0GiB
- **Storage**: 2TB SSD
- **Package Manager**: Homebrew
- **Shell**: zsh with oh-my-zsh and Powerlevel10k
- **Terminal**: Warp, shared across both platforms

## Environment Notes

- **Multi-platform dotfiles**: Using chezmoi with templating for Linux and macOS
- **Linux**: CachyOS with Hyprland, gaming-optimized (AMD Radeon RX 7900 XT)
- **macOS**: Development environment with Homebrew
- **RAM**: Running at base clock due to XMP profile instability
- **Shared tools**: Zed editor, Warp terminal, Git configs work on both platforms

## Configuration Management

<!-- Handles instructions for managing configuration files with chezmoi -->

### Multi-Platform Architecture

This chezmoi repository supports **both Linux and macOS**:

- **Platform detection**: chezmoi automatically detects the OS (`.chezmoi.os`)
- **`.chezmoiignore`**: Excludes platform-specific files (e.g., Hyprland on macOS, systemd on macOS)
- **OS-specific scripts**: `_linux.sh` and `_darwin.sh` suffixes for platform-specific scripts
- **Templates**: `.tmpl` files use conditionals for cross-platform configs (e.g., `dot_zshrc.tmpl`)

**Platform-Specific Configs:**

- **Linux-only**: Hyprland, Waybar, GTK themes, systemd services, Solaar
- **macOS-only**: Homebrew setup scripts
- **Shared**: Zed, Warp terminal, Zsh configs, Git configs, development tools

### Chezmoi Workflow

When making changes to configuration files in `~/.config/`, ALWAYS follow this workflow:

1. **Edit files in chezmoi source directory** (not directly in `~/.config/`)
   - The chezmoi source directory is located at `~/.local/share/chezmoi`
   - Use `chezmoi source-path <file>` to find the chezmoi source location
   - If the file is not managed by chezmoi, notify the user to add it first with `chezmoi add <file>`
   - Then make changes to the chezmoi source file

2. **Apply changes** after editing
   - Run `chezmoi apply` to sync changes to the live config
   - This ensures changes are tracked and can be deployed to other systems
   - Changes are automatically filtered based on the current OS

### Package Management Workflow

When the user installs a new package they want to track across machines:

**On Linux (pacman/paru):**

1. **Check if package is already in the install script:**

   ```bash
   grep -i '<package-name>' ~/.local/share/chezmoi/run_once_before_01-install-packages_linux.sh
   ```

2. **If not present, determine if it should be added:**
   - Check if explicitly installed: `pacman -Qi <package> | grep "Install Reason"`
   - If it shows "Installed as a dependency", it's auto-installed by another package
   - Check what depends on it: `pacman -Qi <package> | grep "Required By"`

3. **Find recently installed packages not in the script:**

   ```bash
   comm -23 <(pacman -Qe | awk '{print $1}' | sort) <(grep -oP '(?<=\s{4})\S+(?=\s+#)' ~/.local/share/chezmoi/run_once_before_01-install-packages_linux.sh | sort) | head -20
   ```

4. **Add to the appropriate category** in `run_once_before_01-install-packages_linux.sh`
   - Don't add if it's a dependency of an existing package
   - Use comments to explain what pulls dependencies
   - Add AUR packages to the `aur_applications` array

**On macOS (Homebrew):**

1. **Add to `run_once_before_01-install-packages_darwin.sh`:**

   ```bash
   # For CLI tools
   brew install <package>

   # For GUI applications
   brew install --cask <app>
   ```

2. **Add to appropriate section** (core tools, dev tools, applications, etc.)

**Commit changes (both platforms):**

```bash
chezmoi git -- add run_once_before_01-install-packages_*.sh
chezmoi git -- commit -m "Add <package-name> to install script"
chezmoi git -- push
```
