# Linux (CachyOS Noctalia) Setup Guide

How to use this chezmoi repository on the **CachyOS Hyprland–Noctalia spin**.

## Quick Start

Install the CachyOS Noctalia spin from the ISO, then:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

This will:
1. Prompt once for machine type and weather location (stored in `~/.config/chezmoi/chezmoi.toml`).
2. Apply the tracked dotfiles.
3. Run `run_onchange_after_install-packages_linux.sh` to install the package manifest via **shelly**.

Run this from an interactive shell — shelly needs to prompt for sudo.

## What the Spin Provides (not tracked here)

The `cachyos-hypr-noctalia` meta-package and `/etc/skel` supply the whole desktop, so none of it is in this repo:

- Hyprland compositor + its `~/.config/hypr/*.lua` config
- The **Noctalia** shell (Quickshell), autostarted via `qs -c noctalia-shell`
- kitty terminal, GTK/Qt theming (adw-gtk3, qt6ct), portals, `uwsm`
- PipeWire/WirePlumber audio, NetworkManager, Bluetooth
- Base system, kernels, firmware, filesystem tools

To change any of these, edit the live file under `~/.config` (or add just that file to chezmoi if it's worth versioning).

## Package Management (shelly only)

Additions on top of the spin live in `dot_local/share/dotfiles/packages-linux.txt`. The installer script hands the whole list to `shelly install` (idempotent — installed packages are skipped) and re-runs automatically whenever the manifest changes.

**Never use pacman or paru to install** on this branch — shelly resolves repo, AUR, and Flatpak uniformly.

### Adding a package

1. Add the package name to `dot_local/share/dotfiles/packages-linux.txt`.
2. `chezmoi apply` — the manifest hash changes, so the installer re-runs.

### Finding untracked explicit packages

```bash
comm -23 <(pacman -Qeq | sort) \
         <(grep -vE '^\s*(#|$)' dot_local/share/dotfiles/packages-linux.txt | sort)
```
(`pacman -Qeq` is a read-only query; installs go through shelly.)

## Noctalia Settings

`dot_config/noctalia/create_settings.json.tmpl` seeds `~/.config/noctalia/settings.json` **once**. Noctalia rewrites this file as you change settings in its UI, so chezmoi never overwrites it after the first apply. `colors.json` and other generated state are ignored.

To re-seed from the repo (discarding live changes): delete `~/.config/noctalia/settings.json`, then `chezmoi apply`.

## Maintenance

```bash
shelly upgrade         # Full system upgrade
shelly remove <pkg>    # Remove a package
chezmoi diff           # Preview dotfile changes
chezmoi apply          # Apply
hyprctl reload         # Reload Hyprland after live config edits
```

Handy zsh aliases: `update` (`sudo pacman -Syu`), `cleanup` (remove orphans), `jctl` (journal errors), `n` (ninja), `c` (clear).

## Post-Install

```bash
rustup default stable                              # initialize Rust toolchain
```

Gaming CPU-governor service (root-level, not chezmoi-managed): see `SYSTEM_CONFIG.md`.

## Troubleshooting

**Audio** — `systemctl --user restart pipewire pipewire-pulse wireplumber`

**Noctalia shell** — restart with `qs -c noctalia-shell` (or re-login); logs via `journalctl --user`.

**Hyprland** — logs at `~/.cache/hyprland/hyprland.log`.

## Hardware Notes

- **AMD Ryzen 9 7950X3D** — gaming CPU-governor service in `SYSTEM_CONFIG.md`.
- **AMD Radeon RX 7900 XT** — Mesa/Vulkan via the manifest; ROCm included.
- **128GB RAM** — XMP can be unstable; running base clocks for stability.
