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

Hyprland config (`~/.config/hypr/*.lua`), kitty, GTK/Qt theming, and portals come from `cachyos-hypr-noctalia` via `/etc/skel`. Hyprland autostarts Noctalia **v5** (`noctalia`, with an isolated config/state home). Most of this stays outside the repo — edit it live; only files worth version-controlling (e.g. the Noctalia autostart/keybinds tweaks below) are added here. The old v4 shell (`noctalia-shell`/`noctalia-qs`, Quickshell, launched via `qs -c noctalia-shell`) has been fully retired.

### Tracked configs

- `dot_config/noctalia-v5/` — Noctalia **v5** config: hand-written `config.toml.tmpl` (theme, bar, shell, idle, weather, wallpaper, lockscreen), `templates.toml`, custom palettes, and the Beeper user template. Uses an isolated config/state home via `NOCTALIA_CONFIG_HOME`/`NOCTALIA_STATE_HOME` (set in `dot_config/environment.d/noctalia-v5.conf` and inlined in the hypr lua). GUI tweaks land in the state `settings.toml` (untracked, app-owned) and override `config.toml`; durable ones are folded back into `config.toml`. Community palettes/templates are seeded under `dot_local/private_state/...` (`create_`) or re-fetched by the app.
- `dot_config/hypr/config/{autostart,keybinds}.lua.tmpl` — Noctalia v5 autostart + IPC keybinds (home paths templated with `{{ .chezmoi.homeDir }}`).
- `dot_config/zed/` — Zed editor (settings, keymap, themes).
- `dot_config/dxvk.conf` — gaming (DXVK) tweaks.
- `dot_config/millennium/create_config.json` — seeds Millennium's config (active theme = Material-Theme, Source color = Matugen, plus theme tweaks). `create_` so Millennium owns it afterwards. See "Steam theming" below.
- `dot_config/systemd/user/` — a Hyprland uwsm service-timeout override.
- `dot_zshrc`, `dot_bashrc`, `dot_gitconfig`, `dot_p10k.zsh`, `dot_abcde.conf` — shell/tool configs (static; no macOS branches).

### Shell

`dot_zshrc` is static (Linux-only): system-wide powerlevel10k + zsh plugins from `/usr/share/zsh/plugins/`, pacman maintenance aliases, fzf and nvm from `/usr/share`. Secrets are sourced from `~/.secrets/github.env` if present (gitignored).

### Steam theming (Noctalia palette -> Steam UI)

Steam's client UI is recolored to match the Noctalia palette via the **Millennium**
loader (in `packages-linux.txt`) + the **kuska1/Material-Theme** skin. Three parts
must agree, wired up by `run_onchange_after_install-steam-material-theme.sh`:

- **Theme location**: Millennium v3 scans `~/.local/share/Steam/millennium/themes/`
  (NOT the legacy `steamui/skins/`). The script installs the pinned theme there.
- **Noctalia bridge**: the Noctalia community "steam" template (enabled via
  `templates.toml` `community_ids`) writes its generated palette to the legacy
  `~/.steam/steam/steamui/skins/Material-Theme/.../matugen.css`. The script
  symlinks that legacy dir to the real theme so live recolor keeps working
  without patching the app-fetched template.
- **`~/.steam/steam` must be a symlink** to `~/.local/share/Steam`. If Noctalia
  paints before Steam's first launch, its `mkdir -p` turns that path into a real
  directory and Steam dies with "Couldn't set up Steam data". The script
  pre-creates the symlink to prevent this.

Build gotcha: Millennium is a Rust AUR build. `rustup` installs with no default
toolchain, so its first build fails ("Could not find toolchain ''") and caches
the empty value. The package-install script runs `rustup default stable` before
the AUR batch to avoid this.

### Config generation

`.chezmoi.toml.tmpl` prompts once for machine type and weather location and stores them under `[data]` for use by templates.

## Docs

- `docs/LINUX_SETUP.md` — setup and maintenance guide.
- `docs/SYSTEM_CONFIG.md` — root-level configs chezmoi can't manage (gaming CPU governor).

## Hardware Context

- AMD Ryzen 9 7950X3D, 128GB RAM, AMD Radeon RX 7900 XT.
- AMD GPU drivers + ROCm are in the package manifest; gaming env vars live in the spin's Hyprland config.
