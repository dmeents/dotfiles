# Noctalia v5 config notes

Migration from v4 (`noctalia-shell`/`noctalia-qs`, Quickshell) to v5 (native
C++/OpenGL ES `noctalia`) is **complete** — v4 is uninstalled and no longer runs.
The isolated config/state home introduced during the migration is kept: it namespaces
v5 cleanly and leaves room to run another instance later without collisions.
Only `*.toml` files here are loaded; this `.md` is ignored.

## Isolation
- `NOCTALIA_CONFIG_HOME=~/.config/noctalia-v5`  → config dir `~/.config/noctalia-v5/noctalia/`
- `NOCTALIA_STATE_HOME=~/.local/state/noctalia-v5` → GUI overrides at `.../noctalia/settings.toml`
- Set in `~/.config/environment.d/noctalia-v5.conf`; also inlined in the Hyprland
  autostart + keybinds so `noctalia` / `noctalia msg` always target this instance.

## Config layout
- `config.toml` — hand-written base config (theme, bar, shell, idle, weather, wallpaper).
  Durable GUI tweaks are folded back here from `settings.toml` so they reproduce on a
  fresh machine.
- `settings.toml` (under STATE home) — app-owned GUI state; **overrides** `config.toml`
  at runtime. Not tracked (self-rewrites); ephemeral bits (current wallpaper, widget
  positions) stay machine-local.
- `templates.toml` — built-in + community + user template config.
- `palettes/*.json` — custom palettes: Oxide (active), Gruvbox Material, Oasis Abyss
  (ported from v4 `colorschemes/<X>/<X>.json`; token format identical).

## What moved from v4
- Beeper user template: v4 `user-templates.toml [templates.beeper]` →
  `templates.toml [theme.templates.user.beeper]`. Same `{{colors.*}}` grammar +
  `lighten/darken` filters.
- Built-in app templates enabled: kitty, ghostty, alacritty, gtk3, gtk4, qt,
  kcolorscheme, btop.
- **zed + steam**: no v5 built-in → supplied via **community templates**
  (`enable_community_templates`, `community_ids = ["zed","steam"]`). The template
  files are seeded under `~/.local/state/noctalia-v5/noctalia/community-templates/`
  and tracked with the `create_` prefix so the app owns them after first apply.

## Plugins → built-in
- **polkit-agent** → built-in `shell.polkit_agent = true`.
- **cliphist** → built-in `shell.clipboard_enabled = true`.
- **privacy-indicator** → built-in privacy OSD (`osd.kinds.privacy`) + `shell.privacy`
  cam/mic filters. (No persistent bar indicator equivalent confirmed.)
- **screen-toolkit**:
  - screenshots → built-in (`screenshot-region`, `screenshot-fullscreen`), bound to Print / Super+Print.
  - screen recording → official plugin `noctalia/screen_recorder` (enable in
    Settings → Plugins, or `noctalia msg plugins enable ...`), then bind Super+R
    via `noctalia msg plugin <author/plugin:entry> <target> <event>`.
  - color picker, annotation, OCR → **no v5 built-in or official plugin**. Gaps.
    Fallback: external tools (hyprpicker, tesseract) via plain keybinds if wanted.

## Remaining gaps to revisit
- No template (built-in or community) for **discord** or **zenBrowser** (v4 had them).
- **hyprland border-color template**: left DISABLED. Enabling `hyprland` in
  `templates.toml builtin_ids` makes Noctalia write its own `~/.config/hypr/noctalia.lua`
  include and own the border colors — turn on only if you want that.
- **Super+A** maps to `panel-toggle control-center notification`; confirm the section
  context name against the current v5 build (v5 has no standalone notifications panel).
- Two-line clock styling and first-day-of-week (FAQ: v5 follows system locale) not ported.
