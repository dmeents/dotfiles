# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Chezmoi dotfiles repository managing system configurations across two platforms:
- **Linux**: CachyOS with Hyprland (Wayland compositor)
- **macOS**: Homebrew-based environment

Source directory: `~/.local/share/chezmoi` — all edits happen here, never in `~/` or `~/.config/` directly.

## Chezmoi Conventions

- `dot_` prefix → dotfile (`dot_zshrc` → `~/.zshrc`, `dot_config/` → `~/.config/`)
- `executable_` prefix → file gets execute permission
- `.tmpl` suffix → processed as Go template with chezmoi variables
- `run_once_before_*` → scripts run once before file application (package installation)
- `run_onchange_after_*` → scripts run after file application when their content changes
- `_linux` / `_darwin` suffixes → OS-specific scripts
- `.chezmoiignore` → templated file that excludes platform-specific configs per OS

## Essential Commands

```bash
chezmoi apply              # Sync source files to home directory
chezmoi diff               # Preview what would change
chezmoi edit <file>        # Edit the source version of a managed file
chezmoi add <file>         # Add a new file to chezmoi management
chezmoi source-path <file> # Find source location of a managed file
chezmoi status             # Show files that differ from source
chezmoi update             # Pull remote changes and apply
chezmoi git -- <command>   # Run git in chezmoi source directory
hyprctl reload             # Reload Hyprland after config changes (Linux)
```

## Critical Workflow

1. Find source file: `chezmoi source-path ~/.config/hypr/hyprland.conf`
2. Edit in `~/.local/share/chezmoi/`, not the live config
3. Preview: `chezmoi diff`
4. Apply: `chezmoi apply`
5. Reload if needed (e.g., `hyprctl reload`, `source ~/.zshrc`)

## Architecture

### Platform Branching

Platform-specific behavior is handled at three levels:
- **`.chezmoiignore`**: Entire directories excluded per OS (e.g., `hypr/` excluded on macOS, `aerospace/` excluded on Linux)
- **Script suffixes**: `_linux.sh` and `_darwin.sh` scripts only run on their respective OS
- **Templates**: `dot_zshrc.tmpl` uses `{{ if eq .chezmoi.os "linux" }}` conditionals for OS-specific shell config

### Hyprland Configuration (Linux)

Modular design — `hyprland.conf` sources individual files from `config/`:
- `animations.conf`, `autostart.conf`, `colors.conf`, `decorations.conf`, `defaults.conf`
- `environment.conf`, `input.conf`, `keybinds.conf`, `monitor.conf`, `variables.conf`, `windowrules.conf`
- Related daemons: `hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf`

### Waybar (Linux)

Status bar with JSON config, CSS styling, and custom script-based modules in `modules/` (weather, spotify, mail, storage).

### Shell Configuration

`dot_zshrc.tmpl` is the only templated shell file. It conditionally loads:
- **Linux**: system-wide powerlevel10k and plugins from `/usr/share/zsh/plugins/`, pacman/paru aliases
- **macOS**: Homebrew-installed plugins, brew aliases, no oh-my-zsh

Secrets loaded from `~/.secrets/github.env` if present (gitignored).

### Package Management

**Linux** (`run_once_before_02-install-packages_linux.sh`): 390+ packages split between pacman (official) and paru (AUR), organized by category. Uses `--needed` to skip already-installed packages.

**macOS** (`run_once_before_01-install-packages_darwin.sh`): Homebrew formulae and casks.

To find explicitly installed packages not yet tracked:
```bash
comm -23 <(pacman -Qe | awk '{print $1}' | sort) <(grep -oP '(?<=\s{4})\S+(?=\s+#)' run_once_before_02-install-packages_linux.sh | sort) | head -20
```

### Zed Editor

Settings at `dot_config/zed/` — JetBrains keymap, Claude AI integration, biome/eslint/prettier formatting, MCP context servers configured.

## Hardware Context

- AMD Ryzen 9 7950X3D / Ryzen 7 9550x3D, 128GB RAM, AMD Radeon RX 7900 XT
- AMD-specific GPU drivers and ROCm in package list
- Gaming environment variables in `hypr/config/environment.conf`
