#!/bin/bash
# Enable and scope Baloo, the KDE file indexer that backs Dolphin's search.
#
# Why this is needed: baloo had never run on this machine -- no index database, no
# ~/.config/baloofilerc, no baloo_file process. With no index, Dolphin falls back to the
# `filenamesearch:` KIO worker, which walks the filesystem live on every search. Paired
# with the old dolphinrc default (Location=Everywhere + What=FileContents) that meant
# "recursively walk $HOME and grep every byte of every file" -- which is why search was
# unusably slow and returned poor results. dot_config/dolphinrc now sets What=FileName,
# and this script gives that setting a real index to hit.
#
# Scoping matters for more than speed. contentIndexing stores file *contents* in the
# index, so the exclude list below is a security boundary, not an optimization: secrets,
# GPG/pass stores, and kube/docker credentials must never be ingested into a searchable
# database. Baloo's `hidden=no` default already skips every dotfile directory, so most of
# these are belt-and-braces -- but a single future `hidden=yes` would silently sweep all
# of them in, so they are excluded explicitly and permanently.
#
# Uses `balooctl6 config` rather than hand-authored baloofilerc INI so the key spellings
# stay version-correct, and so baloo keeps ownership of its own bookkeeping keys
# (dbVersion, exclude filters version, first-run markers) instead of fighting chezmoi
# over them. Idempotent; run_onchange => re-runs only when this script changes.
set -uo pipefail

if ! command -v balooctl6 >/dev/null 2>&1; then
    echo "==> balooctl6 not found (baloo comes with dolphin); skipping."
    exit 0
fi

# Directories never to index. Credential stores first -- see the header.
EXCLUDE_FOLDERS=(
    "$HOME/.secrets"
    "$HOME/.password-store"
    "$HOME/.gnupg"
    "$HOME/.pki"
    "$HOME/.kube"
    "$HOME/.docker"
    "$HOME/.claude"
    # Bulk / churn: nothing here is worth searching, and all of it is expensive.
    "$HOME/.cache"
    "$HOME/.var"
    "$HOME/.steam"
    "$HOME/.local/share/Steam"
    "$HOME/Downloads"
)

# Directory/file name globs to skip anywhere in the tree. Baloo ships its own defaults
# (*~, *.part, ...); these are the build and dependency trees that dominate ~/Projects
# and ~/Documents/projects. Note .git is already skipped by the hidden=no default.
EXCLUDE_FILTERS=(
    node_modules
    target
    dist
    build
    .next
    .turbo
    .venv
    __pycache__
    vendor
)

# Current value of a baloo list parameter, one entry per line, whitespace and any
# trailing slash stripped so membership tests are exact.
baloo_list() {
    balooctl6 config show "$1" 2>/dev/null \
        | tail -n +2 \
        | sed 's/^[[:space:]]*//; s#/*$##' \
        | sed '/^$/d'
}

# `balooctl6 config add` appends unconditionally, so guard every add to stay idempotent.
baloo_add() {
    local param="$1" value="$2"
    if baloo_list "$param" | grep -qxF "$value"; then
        return 0
    fi
    echo "    + $param: $value"
    balooctl6 config add "$param" "$value" >/dev/null
}

echo "==> Configuring baloo indexer"

# Content indexing on (grep-inside-files search); hidden folders off (see header).
# Both are baloo's defaults -- set explicitly so the intent is declarative.
balooctl6 config set contentIndexing yes >/dev/null
balooctl6 config set hidden no >/dev/null

for d in "${EXCLUDE_FOLDERS[@]}"; do
    [ -d "$d" ] || continue
    baloo_add excludeFolders "${d%/}"
done

for f in "${EXCLUDE_FILTERS[@]}"; do
    baloo_add excludeFilters "$f"
done

# Enable the systemd unit, NOT `balooctl6 enable`. This is the important part, and the
# reason is specific to a non-Plasma session:
#
#   `balooctl6 enable` does not register anything with systemd -- it just forks
#   /usr/lib/kf6/baloo_file as a child of the calling shell. Run from a terminal, the
#   indexer lands in that terminal's app-*.scope cgroup and dies with it. It looks like
#   it worked (`balooctl6 status` reports "running", the file count climbs) while nothing
#   will ever start it again at the next login.
#
# Durable startup comes from kde-baloo.service, whose [Install] WantedBy is
# graphical-session.target -- a target UWSM does reach on this Hyprland session. The
# packaged unit's ExecCondition needs a plasma-workspace binary that isn't installed
# here; dot_config/systemd/user/kde-baloo.service.d/override.conf clears it, so that
# drop-in must be applied before this runs (it is: run_ scripts sort after files).
#
# daemon-reload picks up the drop-in; --now also starts it this session. The first full
# index build runs in the background and must not block the rest of `chezmoi apply`.
# A headless apply has no session bus and no graphical-session.target, hence the guard.
echo "==> Enabling indexer (kde-baloo.service)"
systemctl --user daemon-reload 2>/dev/null || true
if ! systemctl --user enable --now kde-baloo.service 2>&1; then
    echo "    (enable failed -- no session bus? re-run inside the desktop session)"
fi
# Queue anything the index does not cover yet. Harmless if the daemon is not up.
balooctl6 check || true

# Assert it actually landed, and say so loudly if not. This must not be a silent
# `|| true`: dolphinrc sets [Search] Location=Everywhere, which is an indexed lookup and
# is only correct while the indexer runs. The previous version of this script swallowed
# the failure -- so the config-set/config-add calls above succeeded, baloofilerc looked
# fully configured, and kde-baloo.service sat disabled behind a missing ExecCondition
# binary for weeks. The only symptom was "Dolphin search misses new files".
#
# Three independent signals, because they can and did disagree:
#   is-enabled  -- will it come back at the next login?
#   is-active   -- is systemd, specifically, running it? (catches the shell-child case
#                  above, where balooctl reports "running" but systemd owns nothing)
#   balooctl    -- is the daemon actually answering on the bus?
# There is deliberately no `balooctl6 config show` check: indexing-enabled is NOT a
# config parameter (only contentIndexing/hidden/exclude* are), and baloofilerc's
# Indexing-Enabled key is absent-means-true, so its absence proves nothing either way.
unit_enabled=$(systemctl --user is-enabled kde-baloo.service 2>/dev/null || true)
unit_active=$(systemctl --user is-active kde-baloo.service 2>/dev/null || true)
if balooctl6 status 2>/dev/null | grep -qi 'indexer is running'; then
    running=yes
else
    running=no
fi

if [ "$unit_enabled" = "enabled" ] && [ "$unit_active" = "active" ] && [ "$running" = yes ]; then
    echo "==> Baloo enabled and indexing. The first full build runs in the background."
    echo "    Progress:  balooctl6 monitor"
    echo "    Status:    balooctl6 status        # expect 'is running' + rising count"
    echo "    Verify excluded:  balooctl6 status ~/.secrets   # expect: not indexed"
else
    echo "!!! WARNING: baloo is configured but NOT DURABLY INDEXING." >&2
    echo "    is-enabled=${unit_enabled:-<unknown>} is-active=${unit_active:-<unknown>} daemon=${running}" >&2
    echo "    Dolphin's [Search] Location=Everywhere will query a STALE index until fixed." >&2
    echo "    Do NOT 'fix' this with 'balooctl6 enable' -- that forks baloo_file off your" >&2
    echo "    shell and it dies with the terminal. From inside the desktop session:" >&2
    echo "      systemctl --user daemon-reload" >&2
    echo "      systemctl --user enable --now kde-baloo.service" >&2
    echo "    If it still refuses, check ExecCondition:  systemctl --user cat kde-baloo.service" >&2
fi
