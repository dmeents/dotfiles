# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a **chezmoi dotfiles repository** that manages system configuration files for a CachyOS Linux system running Hyprland window manager. The repository uses chezmoi's naming conventions where files prefixed with `dot_` become dotfiles (e.g., `dot_zshrc` → `~/.zshrc`) and `executable_` files become executable scripts.

## Essential Commands

### Chezmoi Core Workflow
```bash
# View source location of a managed file
chezmoi source-path <file>

# Apply changes from chezmoi source to system
chezmoi apply

# Edit a file in the source directory
chezmoi edit <file>

# Show what would change
chezmoi diff

# Add new file to chezmoi
chezmoi add <file>

# Check system status
chezmoi status

# Update from remote and apply
chezmoi update

# Run git commands in source directory
chezmoi git -- <git-command>
```

### Daily Development
```bash
# Apply all pending changes
chezmoi apply

# View differences before applying
chezmoi diff

# Check repository status
chezmoi status

# Test Hyprland config changes (reload compositor)
hyprctl reload
```

## Critical Workflow Rules

### Always Edit Source Files, Not Live Configs
When modifying configuration files:

1. **DO NOT** edit files directly in `~/.config/` or `~/`
2. **ALWAYS** edit files in the chezmoi source directory (`~/.local/share/chezmoi`)
3. Run `chezmoi source-path <file>` to find the source location
4. After editing source files, run `chezmoi apply` to sync changes

Example workflow:
```bash
# Find source file
chezmoi source-path ~/.config/hypr/hyprland.conf
# Edit: ~/.local/share/chezmoi/dot_config/hypr/hyprland.conf

# Apply changes
chezmoi apply
```

### File Naming Conventions
- `dot_` prefix → becomes dotfile (e.g., `dot_zshrc` → `.zshrc`)
- `executable_` prefix → file becomes executable
- Combined: `executable_logout.sh` → executable script
- Directories: `dot_config` → `.config/`

## Architecture

### Configuration Structure

The repository is organized into several key areas:

**Hyprland Window Manager** (`dot_config/hypr/`)
- Modular configuration split across `config/*.conf` files
- Main config: `hyprland.conf` sources all module configs
- Modules: `animations.conf`, `autostart.conf`, `decorations.conf`, `environment.conf`, `input.conf`, `keybinds.conf`, `monitor.conf`, `variables.conf`, `windowrules.conf`
- Scripts: `scripts/executable_logout.sh`
- Utilities: `hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf`

**Waybar Status Bar** (`dot_config/waybar/`)
- JSON config and CSS styling
- Custom modules in `modules/` directory (storage, spotify, mail, weather)
- Python/shell scripts for dynamic content

**Shell Configuration**
- `dot_zshrc`: Zsh configuration with oh-my-zsh, powerlevel10k theme
- `dot_p10k.zsh`: Powerlevel10k theme configuration
- `dot_bashrc`: Basic bash configuration

**Other Configurations**
- `dot_config/zed/`: Zed editor settings
- `dot_config/gtk-*/`: GTK theme settings
- `dot_config/wlogout/`: Logout menu styling
- `dot_config/solaar/`: Logitech device manager config
- `dot_config/vicinae/`: Vicinae tool config

### System-Level Configurations

See `SYSTEM_CONFIG.md` for configurations requiring root privileges:
- CPU governor service for gaming performance
- System-level optimizations

### Hardware-Specific Context

From `dot_config/warp-terminal/rules/system_info.md`:
- AMD Ryzen 7 9550x3D CPU
- 128GB RAM (running at base clock due to XMP instability)
- AMD Radeon RX 7900 XT GPU
- Gaming-optimized environment variables in Hyprland config
- MESA anti-lag disabled due to stuttering issues

## Common Tasks

### Making Configuration Changes

1. Identify the file to modify
2. Find its source location: `chezmoi source-path <file>`
3. Edit the source file in `~/.local/share/chezmoi`
4. Preview changes: `chezmoi diff`
5. Apply changes: `chezmoi apply`
6. For Hyprland changes: `hyprctl reload`

### Adding New Files

```bash
# Add existing file to chezmoi
chezmoi add ~/.config/newapp/config.conf

# This creates: dot_config/newapp/config.conf
# Edit and apply as needed
```

### Committing Changes

```bash
# From anywhere
chezmoi cd
git add .
git commit -m "Description of changes"
git push
exit  # Return to previous directory
```

Or use:
```bash
chezmoi git -- add .
chezmoi git -- commit -m "Description"
chezmoi git -- push
```

### Testing Changes

- **Hyprland**: Changes require `hyprctl reload` or re-login
- **Zsh**: Run `source ~/.zshrc` or open new terminal
- **Waybar**: Kill and restart waybar or use reload command
- **Most configs**: Log out and back in to test fully

## Shell Environment Notes

- Default shell: zsh with oh-my-zsh and powerlevel10k
- Shell plugins: git, fzf, extract, syntax-highlighting, autosuggestions, history-substring-search
- Package manager: pacman (Arch-based)
- Common aliases defined in `dot_zshrc` for system updates and maintenance
