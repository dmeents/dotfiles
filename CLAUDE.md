# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Chezmoi dotfiles for a single Linux workstation running the **CachyOS Hyprland–Noctalia spin** (Wayland). This branch is intentionally Linux-only and minimal: it tracks *only* what differs from a stock Noctalia-spin install.

Source directory: `~/.local/share/chezmoi` — all edits happen here, never in `~/` or `~/.config/` directly.

## Guiding Principle

The CachyOS Noctalia spin already provides the entire desktop (Hyprland config, Noctalia shell, GTK/Qt theming, kitty, portals, base system) via the `cachyos-hypr-noctalia` meta-package and `/etc/skel`. **Do not track anything the spin provides by default.** Only genuine additions (extra apps, personal tweaks) belong here.

## System-level config: codify vs document

Chezmoi's managed-file model targets `$HOME` applied as your unprivileged user, so `/etc` and other root-owned files can't be tracked as ordinary `dot_` files. But that does **not** mean root/system config is off-limits — a `run_onchange_after_*` script can shell out to `sudo` and deploy it (the package installer and Steam-theme scripts already do). The real question is not "who owns the file" but **whether the change is safe to reassert unattended**:

- **Codify** it as a `run_onchange_after_*` script when the change is file-based, idempotent, and safe to re-run without a human watching (e.g. dropping a udev rule and reloading udev). The script embeds the file content, so it stays version-controlled and reproducible on a fresh install.
- **Document** it in `docs/SYSTEM_CONFIG.md` when it is interactive/one-time (firmware, UEFI, disk layout), non-idempotent or risky to blindly re-run, or owned by tooling you shouldn't fight (something CachyOS already manages).

Before codifying anything system-level, verify the *actual* current state (`systemctl is-enabled`, read the live sysfs/`/etc` value) — codify reality, not what a doc claims. Privileged run scripts execute as root on every apply, so keep them few and idempotent; don't automate marginal one-offs.

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
- Installer: `run_onchange_after_install-packages_linux.sh.tmpl`. It embeds the manifest's sha256, so editing the manifest re-triggers the script on the next `chezmoi apply`. It classifies each manifest entry and installs repo packages via `shelly install standard -n <pkgs>` and AUR names via `shelly install aur -n <pkgs>` (idempotent — already-installed packages are skipped) and fails loudly if shelly errors. Note: shelly 3.x uses typed install subcommands (`shelly install standard|aur|flatpak|appimage`); the old flat `shelly install <pkgs>` / `shelly aur install` forms were removed in 3.0.
- Because installs need privilege escalation, run `chezmoi apply` in an interactive shell so shelly can prompt for sudo.

To find explicitly-installed packages not yet in the manifest:
```bash
comm -23 <(pacman -Qeq | sort) <(grep -vE '^\s*(#|$)' dot_local/share/dotfiles/packages-linux.txt | sort)
```
(`pacman -Qeq` is a read-only query; installs still go through shelly.)

## Essential Commands

```bash
chezmoi apply              # Sync source files to home directory (runs the shelly installer if manifest changed)
chezmoi diff               # Preview what would change
chezmoi edit <file>        # Edit the source version of a managed file
chezmoi source-path <file> # Find source location of a managed file
chezmoi status             # Show files that differ from source
chezmoi git -- <command>   # Run git in the chezmoi source directory
shelly upgrade all         # Full system upgrade (all backends; shelly 3.x requires the subcommand)
hyprctl reload             # Reload Hyprland after config changes
```

## Architecture

### Desktop (provided by the spin — NOT tracked)

Hyprland config (`~/.config/hypr/*.lua`), kitty, GTK/Qt theming, and portals come from `cachyos-hypr-noctalia` via `/etc/skel`. Hyprland autostarts Noctalia **v5** (`noctalia`, with an isolated config/state home). Most of this stays outside the repo — edit it live; only files worth version-controlling (e.g. the Noctalia autostart/keybinds tweaks below) are added here. The old v4 shell (`noctalia-shell`/`noctalia-qs`, Quickshell, launched via `qs -c noctalia-shell`) has been fully retired.

### Tracked configs

- `dot_config/noctalia-v5/` — Noctalia **v5** config: hand-written `config.toml.tmpl` (theme, bar, shell, idle, weather, wallpaper, lockscreen), `templates.toml`, custom palettes, and the Beeper user template. Uses an isolated config/state home via `NOCTALIA_CONFIG_HOME`/`NOCTALIA_STATE_HOME` (set in `dot_config/environment.d/noctalia-v5.conf` and inlined in the hypr lua). GUI tweaks land in the state `settings.toml` (untracked, app-owned) and override `config.toml`; durable ones are folded back into `config.toml`. Community palettes/templates are seeded under `dot_local/private_state/...` (`create_`) or re-fetched by the app.
- `dot_config/hypr/config/{autostart,keybinds}.lua.tmpl` — Noctalia v5 autostart + IPC keybinds (home paths templated with `{{ .chezmoi.homeDir }}`).
- `dot_config/hypr/config/windowrules.lua` — wholesale override of the spin's window rules (the loader `hyprland.lua` uses a fixed `require` list, so a tracked file must replace, not supplement). The body is the spin's file verbatim; the only local addition is the "Personal overrides" block at the end pinning **Path of Exile 2 to workspace 2** with fake-fullscreen (`fullscreen_state = "0 2"`), placed after the spin's Gaming section so it wins. When resyncing the spin, re-copy its `windowrules.lua` and re-append that block.
- `dot_config/zed/` — Zed editor (settings, keymap, themes).
- `dot_config/dxvk.conf` — gaming (DXVK) tweaks (input latency, VSync, GPL). Only read because `dot_config/environment.d/gaming.conf` sets `DXVK_CONFIG_FILE` to it; DXVK otherwise auto-loads only a `dxvk.conf` in the game's CWD.
- `dot_config/environment.d/gaming.conf` — GPU/gaming session env vars (`DXVK_CONFIG_FILE`, `DXVK_STATE_CACHE_PATH`, `AMD_VULKAN_ICD=RADV`, `VKD3D_CONFIG`). Imported by systemd into the uwsm session and pushed to the activation env by `autostart.lua`, so games launched from Hyprland inherit them. Obsolete knobs from the old pre-v5 `environment.conf` (`RADV_PERFTEST`, `DXVK_ASYNC`, `WINE_CPU_TOPOLOGY`) are deliberately omitted — see the file's comments.
- `dot_config/millennium/create_config.json` — seeds Millennium's config (active theme = Material-Theme, Source color = Matugen, plus theme tweaks). `create_` so Millennium owns it afterwards. See "Steam theming" below.
- `dot_config/systemd/user/` — a Hyprland uwsm service-timeout override.
- `dot_config/autostart/solaar.desktop` — XDG autostart entry that launches Solaar (Logitech device manager, in the manifest) at login via `solaar --window=hide` (starts hidden to the tray). The spin runs under UWSM, whose `wayland-session-xdg-autostart@hyprland.desktop.target` processes `~/.config/autostart`, so this is the correct autostart path rather than `hypr/config/autostart.lua` (see that file's header comment).
- `dot_fish_profile`, `dot_bashrc`, `dot_gitconfig`, `dot_config/starship.toml`, `dot_abcde.conf` — shell/tool configs (static; Linux-only).
- `run_onchange_after_install-usb-wake-rule.sh` — codified system-level fix: installs `/etc/udev/rules.d/50-usb-keyboard-wake.rules` (via sudo) arming USB remote-wakeup on the `0424:4206` USB4206 hub chain the keyboard hangs off, so a keypress wakes the box from deep sleep. The keyboard and xHCI controller are armed by default but the intermediate hubs aren't, which breaks wake-signal propagation. Matches product `4206` only, to avoid arming the sibling USB7206 hub (`0424:7206`, the 2.5G LAN) for wake-on-LAN.

### Kubernetes (k3s) for CI runners

A lean single-node **k3s** cluster on this workstation, the substrate for GitHub Actions self-hosted runners via **Actions Runner Controller (ARC)**. This replaces the retired Docker-Desktop runner setup: k3s runs as a system-level systemd service on its own bundled containerd, so it survives logout and doesn't churn under load the way the session-bound Docker-Desktop pool did. It coexists with Docker Desktop (engine in a VM).

- `k3s-bin` + `helm` (AUR/repo, in the manifest) — the `k3s-bin` package ships only `/usr/bin/k3s` (no `kubectl` symlink like the upstream installer), so the setup script creates the client symlinks. `helm` drives the in-cluster tooling.
- `run_onchange_after_setup-k3s.sh` — system-level setup: symlinks `kubectl`/`crictl`/`ctr` → `k3s` in `/usr/local/bin` (sudo), writes `/etc/rancher/k3s/config.yaml` (disables Traefik + ServiceLB — nothing here needs them — and sets `write-kubeconfig-mode: 0644`), enables/starts (or restarts, on config change) `k3s.service`, waits for the API, seeds `~/.kube/config` if absent, then installs **Headlamp** (see below) via helm. Sorts after the package installer so k3s + helm are present first.
- **Headlamp** — lightweight CNCF web dashboard, `helm upgrade --install` into the `headlamp` namespace, plus a `headlamp-admin` cluster-admin ServiceAccount for token login. Chosen over Rancher: Rancher caps at k8s 1.35 (this cluster is newer) and needs cert-manager + ingress; Headlamp needs neither. No ingress — reach it via `kubectl -n headlamp port-forward svc/headlamp 8080:80`, then log in with `kubectl -n headlamp create token headlamp-admin`.
- **Not managed here:** the ARC install itself (CRDs, controller, runner scale sets) is applied into the cluster separately (helm/kubectl) — another workstream owns it. This repo owns the k3s substrate + cluster tooling (Headlamp).
- Only up while this workstation is powered on (single-node, on the desktop). API reachable at `https://127.0.0.1:6443`.

### Shell

Fish is the interactive shell. `dot_fish_profile` (`~/.fish_profile`) layers personal deltas on top of the CachyOS fish base config — it only adds what neither fish nor the spin already provide: the Starship prompt init, fzf keybindings, pkgfile command-not-found, `make`/`ninja` all-core wrappers, pacman abbreviations, and an `extract` function. Starship (`dot_config/starship.toml`) replaces the old zsh + powerlevel10k prompt, which has been retired. Secrets are sourced from every `~/.secrets/*.env` file if present (gitignored).

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
- `docs/SYSTEM_CONFIG.md` — system-level config kept as docs rather than codified (see "System-level config: codify vs document" above), plus notes on state that drifted from what was documented.

## Hardware Context

- AMD Ryzen 9 7950X3D, 128GB RAM, AMD Radeon RX 7900 XT.
- AMD GPU drivers + ROCm come via `cachyos-gaming-meta` in the package manifest; gaming/GPU env vars live in `dot_config/environment.d/gaming.conf` (DXVK/RADV/VKD3D), not the spin's Hyprland config.
