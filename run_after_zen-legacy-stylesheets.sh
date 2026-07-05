#!/bin/bash
# Enable userChrome.css / userContent.css loading in Zen so Noctalia's generated
# theme CSS (imported from ~/.cache/noctalia/zen-browser/) actually applies.
#
# Firefox-based browsers ignore legacy profile stylesheets unless
# `toolkit.legacyUserProfileCustomizations.stylesheets` is true. Noctalia writes
# the CSS and the @import stubs, but not this pref — so we set it per profile.
#
# Named to sort AFTER install-packages_linux.sh so zen-browser-bin is present.
# Runs on every apply (not run_once) because Zen creates its profile only on
# first launch: this way the pref lands on a later apply once the profile exists.
# Idempotent: appends to user.js only if the pref is not already present.
set -uo pipefail

ZEN_DIR="$HOME/.config/zen"
[ -d "$ZEN_DIR" ] || exit 0

PREF_LINE='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

set_pref() {
    local profile="$1" userjs="$1/user.js"
    if [ -f "$userjs" ] && grep -qF "toolkit.legacyUserProfileCustomizations.stylesheets" "$userjs"; then
        return 0
    fi
    {
        echo "// Required for Noctalia theming: allow userChrome.css / userContent.css to load"
        echo "$PREF_LINE"
    } >> "$userjs"
    echo "==> Enabled legacy stylesheets pref in ${profile##*/}"
}

# A real Zen profile has a prefs.js (created on first launch). Handle names with
# spaces, e.g. "rq2i9lka.Default (release)".
found=0
while IFS= read -r -d '' prefs; do
    found=1
    set_pref "$(dirname "$prefs")"
done < <(find "$ZEN_DIR" -mindepth 2 -maxdepth 2 -name prefs.js -print0 2>/dev/null)

[ "$found" -eq 0 ] && echo "==> No Zen profile found yet (launch Zen once); skipping"
exit 0
