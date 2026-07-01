# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Chezmoi dotfiles for a single Linux workstation running the **CachyOS Hyprland–Noctalia spin** (Wayland). This branch is intentionally Linux-only and minimal: it tracks *only* what differs from a stock Noctalia-spin install.

Source directory: `~/.local/share/chezmoi` — all edits happen here, never in `~/` or `~/.config/` directly.

## Guiding Principle

The CachyOS Noctalia spin already provides the entire desktop (Hyprland config, Noctalia shell, GTK/Qt theming, kitty, portals, base system) via the `cachyos-hypr-noctalia` meta-package and `/etc/skel`. **Do not track anything the spin provides by default.** Only genuine additions (extra apps, personal tweaks) belong here.

## Chezmoi Conventions

- `dot_` prefix → dotfile (`dot_zshrc` → `~/.zshrc`, `dot_config/` → `~/.config/`)
- `executable_` prefix → file gets execute permission
- `create_` prefix → file is created only if absent in the target, then never overwritten (used to *seed* app-managed files)
- `.tmpl` suffix → processed as a Go template with chezmoi variables
- `run_onchange_after_*` → runs after file application, but only when the script's rendered content changes
- `.chezmoiignore` → excludes paths from being applied

## Package Management — shelly ONLY

`shelly` is the Noctalia spin's unified package manager (repo + AUR + Flatpak). **Never use pacman or paru to install** on this branch.

- Manifest: `dot_local/share/dotfiles/packages-linux.txt` — one package per line, `#` comments and blanks ignored. Contains only additions on top of the spin.
- Installer: `run_onchange_after_install-packages_linux.sh.tmpl`. It embeds the manifest's sha256, so editing the manifest re-triggers the script on the next `chezmoi apply`. It runs `shelly install -n <all manifest packages>` (idempotent — already-installed packages are skipped) and fails loudly if shelly errors.
- Because installs need privilege escalation, run `chezmoi apply` in an interactive shell so shelly can prompt for sudo.

To find explicitly-installed packages not yet in the manifest:
```bash
comm -23 <(pacman -Qeq | sort) <(grep -vE '^\s*(#|$)' dot_local/share/dotfiles/packages-linux.txt | sort)
```
(`pacman -Qeq` is a read-only query; installs still go through shelly.)

## Essential Commands

```bash
chezmoi apply              # Sync source files to home directory (runs shelly install if manifest changed)
chezmoi diff               # Preview what would change
chezmoi edit <file>        # Edit the source version of a managed file
chezmoi source-path <file> # Find source location of a managed file
chezmoi status             # Show files that differ from source
chezmoi git -- <command>   # Run git in the chezmoi source directory
shelly upgrade             # Full system upgrade
hyprctl reload             # Reload Hyprland after config changes
```

## Architecture

### Desktop (provided by the spin — NOT tracked)

Hyprland config (`~/.config/hypr/*.lua`), the Noctalia shell, kitty, GTK/Qt theming, and portals all come from `cachyos-hypr-noctalia` via `/etc/skel`. Hyprland autostarts the shell with `qs -c noctalia-shell`. None of this lives in the repo — edit it live or, if a change is worth version-controlling, add just that file here.

### Tracked configs

- `dot_config/noctalia/create_settings.json.tmpl` — the Noctalia shell settings, **seeded once**. Noctalia rewrites this file at runtime, so `create_` prevents chezmoi from ever overwriting live edits. `colors.json` and other Noctalia state are runtime-generated and ignored.
- `dot_config/zed/` — Zed editor (settings, keymap, themes).
- `dot_config/dxvk.conf` — gaming (DXVK) tweaks.
- `dot_config/systemd/user/` — a Hyprland uwsm service-timeout override.
- `dot_zshrc`, `dot_bashrc`, `dot_gitconfig`, `dot_p10k.zsh`, `dot_abcde.conf` — shell/tool configs (static; no macOS branches).

### Shell

`dot_zshrc` is static (Linux-only): system-wide powerlevel10k + zsh plugins from `/usr/share/zsh/plugins/`, pacman maintenance aliases, fzf and nvm from `/usr/share`. Secrets are sourced from `~/.secrets/github.env` if present (gitignored).

### Config generation

`.chezmoi.toml.tmpl` prompts once for machine type and weather location (used by the Noctalia settings template) and stores them under `[data]`.

## Docs

- `docs/LINUX_SETUP.md` — setup and maintenance guide.
- `docs/SYSTEM_CONFIG.md` — root-level configs chezmoi can't manage (gaming CPU governor).

## Hardware Context

- AMD Ryzen 9 7950X3D, 128GB RAM, AMD Radeon RX 7900 XT.
- AMD GPU drivers + ROCm are in the package manifest; gaming env vars live in the spin's Hyprland config.
