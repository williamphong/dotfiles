#!/usr/bin/env bash
#
# Symlink this repo's configs into place.
#
# The repo is the single source of truth: every path below becomes a symlink
# pointing back here, so editing the live config and editing the repo are the
# same write. That is the whole point -- a copy-based sync only works if you
# remember to run it, and when you forget, nothing tells you.
#
# Idempotent: safe to re-run any time. Anything real already sitting at a
# target is moved to a timestamped backup rather than deleted.
#
#   ./install.sh              create the links
#   ./install.sh --dry-run    print what would change, touch nothing
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
case "${1:-}" in
  --dry-run) DRY_RUN=1 ;;
  "")        ;;
  *)         echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

# Paths are relative to both the repo root and $HOME -- .config/nvim here
# becomes ~/.config/nvim.
#
# Directories are linked whole rather than file by file. That matters for apps
# that rewrite their config in place: btop rewrites btop.conf on exit and kitty
# writes current-theme.conf, and a wholesale rewrite would replace a file-level
# symlink with a regular file, silently breaking the link. With the directory
# linked, those writes land in the repo where git can see them.
LINKS=(
  .zshrc
  .p10k.zsh
  .bashrc
  .config/nvim
  .config/kitty
  .config/tmux
  .config/btop
  .config/lsd
  .config/fastfetch
  .config/term_colors
  .config/starship.toml
  # spicetify is the one exception to linking a whole directory: it installs
  # 70M of third-party Themes/, CustomApps/ and Extensions/ next to its config,
  # and only this file is ours.
  .config/spicetify/config-xpui.ini
  # kitty's ssh copy resolves paths relative to $HOME, so anything ssh.conf
  # ships has to exist there. This also puts it on PATH locally.
  "bootstrap.sh:.local/bin/dotfiles-bootstrap"
)

link() {
  # An entry is either "path", when the name is the same on both sides, or
  # "src:dst" when the path in $HOME differs from the path in the repo. With no
  # colon both expansions yield the whole string, so the simple case is
  # unaffected.
  local entry="$1"
  local rel="${entry%%:*}"
  local dstrel="${entry#*:}"
  local src="$DOTFILES/$rel"
  local dst="$HOME/$dstrel"

  if [[ ! -e "$src" ]]; then
    printf '  skip     %s (not in repo)\n' "$rel"
    return
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    printf '  ok       %s\n' "$dstrel"
    return
  fi

  # -L as well as -e, so a broken symlink in the way is still cleared.
  if [[ -e "$dst" || -L "$dst" ]]; then
    printf '  backup   %s -> %s\n' "$dstrel" "$BACKUP/$dstrel"
    if (( ! DRY_RUN )); then
      mkdir -p "$(dirname "$BACKUP/$dstrel")"
      mv "$dst" "$BACKUP/$dstrel"
    fi
  fi

  printf '  link     %s\n' "$dstrel"
  if (( ! DRY_RUN )); then
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
  fi
}

(( DRY_RUN )) && echo "DRY RUN -- nothing will be changed"
echo "linking from $DOTFILES"
for rel in "${LINKS[@]}"; do link "$rel"; done

if [[ -d "$BACKUP" ]]; then
  echo
  echo "replaced paths backed up to $BACKUP"
fi
