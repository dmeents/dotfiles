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
- **Shell** — Zsh with Powerlevel10k, system-wide plugins, maintenance aliases.
- **Editor** — Zed (settings, keymap, themes).
- **Noctalia** — the shell's `settings.json` is *seeded once* (`create_`), then owned by Noctalia at runtime.
- **Misc** — DXVK gaming config, a Hyprland uwsm service override, git/bash configs.

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
│   ├── noctalia/create_settings.json.tmpl        # Noctalia settings (seeded once)
│   ├── zed/                                       # Zed editor
│   ├── systemd/user/                              # Hyprland uwsm timeout override
│   └── dxvk.conf
├── dot_zshrc, dot_bashrc, dot_gitconfig, dot_p10k.zsh, dot_abcde.conf
├── dot_local/share/dotfiles/packages-linux.txt   # shelly package manifest
└── run_onchange_after_install-packages_linux.sh.tmpl
```

## 🛠️ Common Commands

```bash
chezmoi diff        # Preview what would change
chezmoi apply       # Apply changes (runs shelly install if the manifest changed)
chezmoi edit ~/.zshrc
chezmoi status
shelly upgrade      # Full system upgrade
```

See **[docs/LINUX_SETUP.md](docs/LINUX_SETUP.md)** for the full guide.

## 📄 License

MIT
