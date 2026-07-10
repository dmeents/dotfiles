# Dotfiles

Personal dotfiles for a Linux workstation running the **CachyOS Hyprland–Noctalia spin**, managed with [chezmoi](https://www.chezmoi.io/).

This repo is deliberately minimal: it tracks only what differs from a stock Noctalia-spin install. The desktop itself (Hyprland, the Noctalia shell, theming, kitty, portals) is provided by the `cachyos-hypr-noctalia` package and is **not** duplicated here.

## 🚀 Quick Start

On a fresh CachyOS Noctalia-spin install:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

`chezmoi init` prompts once for machine type and weather location, then applies the dotfiles and runs the package installer (`shelly`).

## 📋 What's Included

- **Packages** — additions on top of the spin, listed in `dot_local/share/dotfiles/packages-linux.txt` and installed via **shelly** (the spin's package manager; never pacman/paru).
- **Shell** — Fish as the interactive shell (`~/.fish_profile` layered on the CachyOS fish base config) with a Starship prompt; Bash kept for scripting. Secrets are sourced from `~/.secrets/*.env` if present.
- **Editor** — Zed (settings, keymap, themes).
- **Noctalia v5** — the desktop shell. Hand-written `config.toml` (theme, bar, idle, weather, wallpaper, lockscreen) plus custom palettes and user templates, under an isolated config/state home. Runtime GUI tweaks land in the app-owned state file; durable ones are folded back into `config.toml`.
- **Steam theming** — Steam's UI is recolored to the Noctalia palette via the Millennium loader + Material-Theme skin (seeded config + installer script).
- **Misc** — DXVK gaming config (wired in via `environment.d/gaming.conf`), a Hyprland uwsm service override, and git/bash/abcde configs.

## 🗂️ Repository Structure

```
.
├── README.md
├── CLAUDE.md                                     # Guidance for Claude Code
├── docs/
│   ├── LINUX_SETUP.md                            # Setup & maintenance guide
│   └── SYSTEM_CONFIG.md                          # Root-level configs (gaming CPU governor)
├── .chezmoiignore
├── .chezmoi.toml.tmpl                            # Prompts: machine type, weather location
├── dot_config/
│   ├── noctalia-v5/                              # Noctalia v5 config (config.toml, palettes, templates)
│   ├── hypr/config/                              # autostart, keybinds, windowrules, defaults (.lua)
│   ├── environment.d/                            # session env (Noctalia v5 isolation, DXVK/GPU)
│   ├── millennium/                               # Steam UI theming seed (create_)
│   ├── zed/                                      # Zed editor
│   ├── systemd/user/                             # Hyprland uwsm timeout override
│   ├── starship.toml                             # prompt
│   └── dxvk.conf                                 # DXVK gaming tweaks
├── dot_fish_profile, dot_bashrc, dot_gitconfig, dot_abcde.conf
├── dot_local/share/dotfiles/packages-linux.txt   # shelly package manifest
└── run_onchange_after_install-*.sh(.tmpl)        # package + Steam theming installers
```

## 🛠️ Common Commands

```bash
chezmoi diff        # Preview what would change
chezmoi apply       # Apply changes (runs shelly install if the manifest changed)
chezmoi edit ~/.fish_profile
chezmoi status
shelly upgrade      # Full system upgrade
```

See **[docs/LINUX_SETUP.md](docs/LINUX_SETUP.md)** for the full guide.

## 📄 License

MIT
