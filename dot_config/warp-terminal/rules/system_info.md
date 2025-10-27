# System Information
<!-- You should change the system information below to match your own -->

## System Configuration
- **CPU**: AMD Ryzen 7 9550x3D (16) @ 4.3GHz, 5.7GHz boos
- **RAM**: 128.0GiB
- **GPU**: AMD Radeon RX 7900 XT
- **Storage**: 4TB SSD

## Operating System
- **Distribution**: CachyOS Linux (Arch-based)
- **Window Manager**: Hyprland
- **Shell**: fish 4.1.2

## Environment Notes
- Using CachyOS, an Arch Linux derivative optimized for performance
- Running Hyprland for Wayland compositing
- Fish shell for interactive command-line use
- We are running our RAM at the base clock, because when trying to run the XMP profile, the system becomes unstable and crashes.

## Configuration Management
<!-- Handles instructions for managing configuration files with chezmoi -->

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

### Package Management Workflow
When the user installs a new package they want to track across machines:

1. **Check if package is already in the install script:**
   ```bash
   grep -i '<package-name>' ~/.local/share/chezmoi/run_once_before_install-packages.sh
   ```

2. **If not present, determine if it should be added:**
   - Check if explicitly installed: `pacman -Qi <package> | grep "Install Reason"`
   - If it shows "Installed as a dependency", it's auto-installed by another package
   - Check what depends on it: `pacman -Qi <package> | grep "Required By"`

3. **Find recently installed packages not in the script:**
   ```bash
   comm -23 <(pacman -Qe | awk '{print $1}' | sort) <(grep -oP '(?<=\s{4})\S+(?=\s+#)' ~/.local/share/chezmoi/run_once_before_install-packages.sh | sort) | head -20
   ```

4. **Add to the appropriate category** in `run_once_before_install-packages.sh`
   - Don't add if it's a dependency of an existing package
   - Use comments to explain what pulls dependencies

5. **Commit the changes:**
   ```bash
   chezmoi git -- add run_once_before_install-packages.sh
   chezmoi git -- commit -m "Add <package-name> to install script"
   chezmoi git -- push
   ```
