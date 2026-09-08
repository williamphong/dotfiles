#!/usr/bin/env sh
#
# Install the tools .bashrc expects onto a remote host.
#
#   ./bootstrap-remote.sh wp-linux sdsudb    provision those hosts over ssh
#   ./bootstrap-remote.sh                    provision the machine it runs on
#
# Deliberately NOT wired into kitten ssh, and deliberately not called from
# .bashrc. Copying config on every connect is declarative and cheap; fetching
# and executing installers is neither. On a shared or locked-down host that
# should be a decision you make once, not a side effect of logging in.
#
# Everything lands under ~/.local, so no root is needed and nothing outside
# your home directory is touched. Every step is idempotent: re-running only
# fills in what is missing, so it is safe to run again after adding a server.

set -eu

# --- dispatch: with hostnames, pipe this script to each of them over ssh ----
if [ "$#" -gt 0 ]; then
    for host in "$@"; do
        printf '\n=== %s ===\n' "$host"
        # `sh -s` reads the script from stdin; with no arguments the remote
        # copy falls through to the provisioning section below.
        ssh "$host" 'sh -s' < "$0" || printf '  connection or setup FAILED\n'
    done
    printf '\nReconnect (or run `exec bash -l`) for changes to take effect.\n'
    exit 0
fi

# --- from here down we are running on the target machine --------------------
BIN="$HOME/.local/bin"
mkdir -p "$BIN"

have() { command -v "$1" >/dev/null 2>&1; }
say()  { printf '  %-10s %s\n' "$1" "$2"; }

# starship -- the prompt. Its installer defaults to /usr/local/bin and will
# reach for sudo if that is not writable, so --bin-dir is what keeps this a
# userspace install. The directory must already exist; mkdir -p above covers it.
if have starship; then
    say starship "already present ($(starship --version 2>/dev/null | head -1))"
elif ! have curl; then
    say starship "SKIPPED, needs curl"
else
    if curl -sS https://starship.rs/install.sh \
        | sh -s -- --yes --bin-dir "$BIN" >/dev/null 2>&1; then
        say starship "installed to $BIN"
    else
        say starship "FAILED"
    fi
fi

# ble.sh -- syntax highlighting and the transient prompt. Built from source,
# so it needs git and make; plenty of locked-down hosts have neither.
if [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    say ble.sh "already present"
elif ! have git || ! have make; then
    say ble.sh "SKIPPED, needs git and make"
else
    tmp=$(mktemp -d)
    if git clone --recursive --depth 1 --shallow-submodules \
            https://github.com/akinomyoga/ble.sh "$tmp/ble.sh" >/dev/null 2>&1 \
        && make -C "$tmp/ble.sh" install PREFIX="$HOME/.local" >/dev/null 2>&1; then
        say ble.sh "installed to ~/.local/share/blesh"
    else
        say ble.sh "FAILED"
    fi
    rm -rf "$tmp"
fi

# The rest are optional: .bashrc degrades cleanly without them, and they vary
# too much across distros and architectures to install reliably from here.
printf '\n  optional (install via the system package manager if wanted):\n'
for t in lsd nvim fastfetch zoxide direnv; do
    if have "$t"; then say "$t" "present"; else say "$t" "missing"; fi
done
