# Noctalia v4 → v5 (beta) migration notes

v5 (`noctalia`, native C++/OpenGL ES) runs **alongside** v4 (`noctalia-shell` +
`noctalia-qs`, Quickshell). This isolated config/state home keeps them from
interfering. Only `*.toml` files here are loaded; this `.md` is ignored.

## Isolation
- `NOCTALIA_CONFIG_HOME=~/.config/noctalia-v5`  → config dir `~/.config/noctalia-v5/noctalia/`
- `NOCTALIA_STATE_HOME=~/.local/state/noctalia-v5` → GUI overrides at `.../noctalia/settings.toml`
- Set in `~/.config/environment.d/noctalia-v5.conf`; also inlined in the Hyprland
  autostart + keybinds so `noctalia msg` always targets the right instance.

## What moved
- Palettes: v4 `colorschemes/<X>/<X>.json` → v5 `palettes/<X>.json` (token format identical).
  Ported: Oxide (active), Gruvbox Material, Oasis Abyss.
- Beeper user template: v4 `user-templates.toml [templates.beeper]` →
  `templates.toml [theme.templates.user.beeper]`. Same `{{colors.*}}` grammar +
  `lighten/darken` filters (verified rendering clean).
- Built-in app templates enabled: kitty, ghostty, alacritty, gtk3, gtk4, qt,
  kcolorscheme, btop.

## Plugins → mostly built-in now
- **polkit-agent** → built-in `shell.polkit_agent = true`.
- **privacy-indicator** → built-in privacy OSD (`osd.kinds.privacy`) + `shell.privacy`
  cam/mic filters. (No persistent bar indicator equivalent confirmed.)
- **screen-toolkit**:
  - screenshots → built-in (`screenshot-region`, `screenshot-fullscreen`), bound to Print / Super+Print.
  - screen recording → official plugin `noctalia/screen_recorder` (enable in
    Settings → Plugins, or `noctalia msg plugins enable ...`), then bind Super+R
    via `noctalia msg plugin <author/plugin:entry> <target> <event>`.
  - color picker, annotation, OCR → **no v5 built-in or official plugin**. Gaps.
    Fallback: external tools (hyprpicker, tesseract) via plain keybinds if wanted.

## Deferred / gaps to revisit
- **hyprland border-color template**: NOT enabled during coexistence (it would add
  its own include to `~/.config/hypr`). v4 already themes borders with Oxide, so
  colors stay correct. Enable `hyprland` in `templates.toml builtin_ids` at full
  cutover (its `apply.sh` auto-wires the include; user is on the Hyprland *lua*
  config, so it writes `~/.config/hypr/noctalia.lua`).
- No v5 built-in templates for **zed, steam, discord, zenBrowser** (v4 had them).
- **Super+A** mapped to `panel-toggle control-center notification` — confirm the
  section context name; v5 has no standalone notifications panel.
- Two-line clock styling and first-day-of-week (FAQ: v5 follows system locale) not
  ported.

## Fallback to v4
Uncomment the `qs -c noctalia-shell` line in `~/.config/hypr/config/autostart.lua`
(and comment the v5 line), then re-login. v4 config in `~/.config/noctalia/` is
untouched.
