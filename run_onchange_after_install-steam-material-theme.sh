#!/bin/bash
# Install the "Material" Steam theme (kuska1/Material-Theme) for Millennium and
# wire it up to Noctalia's dynamic colors.
#
# Path layout (three moving parts that must agree):
#   * Millennium v3 scans          ~/.local/share/Steam/millennium/themes/
#       -> the real theme is installed there (activeTheme "Material-Theme").
#   * Noctalia's community "steam" template writes its generated palette to the
#     legacy path ~/.steam/steam/steamui/skins/Material-Theme/css/main/colors/
#     matugen.css. We can't easily retarget that app-fetched template, so we
#     bridge it: steamui/skins/Material-Theme -> millennium/themes/Material-Theme
#     (a symlink), so Noctalia's writes land in the real theme and it recolors
#     live on every palette change.
#   * ~/.steam/steam must be a symlink to ~/.local/share/Steam. Steam creates it
#     on first launch, but on a fresh machine Noctalia may paint a palette first
#     -- its mkdir -p would then create ~/.steam/steam as a real directory, which
#     breaks Steam's bootstrap entirely ("Couldn't set up Steam data"). We
#     pre-create the symlink here so that ordering can't bite.
#
# Inert without the Millennium loader (in packages-linux.txt). Idempotent;
# run_onchange => runs on first apply and again only if THEME_REF is bumped.
# After apply: Steam > Settings > Millennium > Themes > Material (seeded active
# via dot_config/millennium/create_config.json), Source color > Matugen.
set -uo pipefail

THEME_REPO="https://github.com/kuska1/Material-Theme"
# Pinned for reproducibility. Bump to update the theme (re-triggers this script).
THEME_REF="0b75b6dea188cadda3a5d085282bf9d175021a81"

STEAM="$HOME/.local/share/Steam"
THEME_DIR="$STEAM/millennium/themes/Material-Theme"   # where Millennium v3 looks
LEGACY_LINK="$STEAM/steamui/skins/Material-Theme"     # where Noctalia writes colors
COLORS="$THEME_DIR/css/main/colors/matugen.css"

# --- Guard: ~/.steam/steam must be a symlink to the Steam data dir -----------
mkdir -p "$STEAM"
if [ ! -L "$HOME/.steam/steam" ]; then
    mkdir -p "$HOME/.steam"
    if [ -e "$HOME/.steam/steam" ]; then
        # A stray real directory is squatting the path -- move it aside.
        mv "$HOME/.steam/steam" "$HOME/.steam/steam.bak-$(date +%s 2>/dev/null || echo old)"
    fi
    ln -s "$STEAM" "$HOME/.steam/steam"
fi

# --- Install the theme into the Millennium v3 themes dir ----------------------
if [ ! -f "$THEME_DIR/skin.json" ]; then
    if ! command -v git >/dev/null 2>&1; then
        echo "==> git not found; cannot install Steam Material-Theme" >&2
        exit 1
    fi
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    echo "==> Cloning Material-Theme @ ${THEME_REF:0:12}"
    if ! git clone --quiet "$THEME_REPO" "$tmp/theme"; then
        echo "==> clone of $THEME_REPO failed" >&2; exit 1
    fi
    if ! git -C "$tmp/theme" checkout --quiet "$THEME_REF"; then
        echo "==> checkout of $THEME_REF failed" >&2; exit 1
    fi
    rm -rf "$tmp/theme/.git"
    # Preserve Noctalia's live colors if it has already written them.
    if [ -f "$COLORS" ]; then cp -f "$COLORS" "$tmp/keep-matugen.css"; fi
    mkdir -p "$THEME_DIR"
    cp -rf "$tmp/theme/." "$THEME_DIR"/
    if [ -f "$tmp/keep-matugen.css" ]; then cp -f "$tmp/keep-matugen.css" "$COLORS"; fi
    echo "==> Material-Theme installed to $THEME_DIR"
else
    echo "==> Material-Theme already installed; skipping clone"
fi

# --- Bridge legacy path (Noctalia's output target) -> real theme dir ----------
mkdir -p "$(dirname "$LEGACY_LINK")"
if [ ! -L "$LEGACY_LINK" ]; then
    if [ -e "$LEGACY_LINK" ]; then
        mv "$LEGACY_LINK" "$LEGACY_LINK.bak-$(date +%s 2>/dev/null || echo old)"
    fi
    ln -s ../../millennium/themes/Material-Theme "$LEGACY_LINK"
fi

echo "==> Steam Material theme ready. Fully restart Steam to load Millennium."
