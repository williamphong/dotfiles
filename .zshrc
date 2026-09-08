# ---------------------------------------------------------------------------
# Path & environment variables
# ---------------------------------------------------------------------------
export PATH="/Users/williamphong/.pixi/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/mysql/bin:$PATH"

export EDITOR="nvim"
export VISUAL="nvim"
export CLICOLOR=1

# spicetify
export SPICETIFY_INSTALL="$HOME/.spicetify"
export PATH="$SPICETIFY_INSTALL:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# openspec
export OPENSPEC_TELEMETRY=0

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY          # don't clobber the file on exit
setopt INC_APPEND_HISTORY      # write as you go, not just at shell exit
setopt SHARE_HISTORY           # share between concurrent shells / tmux panes
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicates of a repeated command
setopt HIST_IGNORE_SPACE       # leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY             # expand !! into the line instead of running it
setopt EXTENDED_HISTORY        # record timestamps and durations

# ---------------------------------------------------------------------------
# Completion system
#
# Must run BEFORE anything that calls compdef (bun, zoxide, fnm, etc.),
# because compdef is not defined until compinit has run.
# ---------------------------------------------------------------------------
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"

autoload -Uz compinit && compinit

# ---------------------------------------------------------------------------
# Tool initialization
# ---------------------------------------------------------------------------
eval "$(fnm env --use-on-cd)"

# zoxide (replaces cd with smart version, keeps cd -, cd .. etc.)
eval "$(zoxide init zsh --cmd cd)"

# bun completions (needs compdef, hence after compinit above)
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# ---------------------------------------------------------------------------
# direnv
#
# Replaces the old hand-rolled pixi chpwd hook, which prepended each project's
# environment to PATH but never removed it on the way out. direnv snapshots the
# environment on entry and restores it on exit, and works from subdirectories.
#
# Requires: brew install direnv
#
# Per pixi project, create a .envrc at the project root containing:
#
#     watch_file pixi.lock
#     eval "$(pixi shell-hook)"
#
# then run `direnv allow` once in that directory.
# ---------------------------------------------------------------------------
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ls="lsd"
alias ll="lsd -lG"
alias vim="nvim"
alias vi="nvim"

# kitty-only helpers.
#
# `kitten ssh` needs two things: kitty must actually be the terminal on this
# end, and stdin/stdout must be TTYs -- it hard-errors with "STDIN must be a
# terminal" otherwise, which breaks every scripted or piped ssh call.
#
# $KITTY_WINDOW_ID alone is NOT a sufficient guard. tmux bakes it into the
# server's global environment when the server is first started from kitty, and
# `update-environment` does not refresh it, so a stale value survives detaching
# and reattaching from Terminal.app. Inside tmux, ask tmux what the *currently
# attached client* is instead of trusting the inherited env.
# ssh and icat were aliases in an earlier version of this file. Aliases expand
# at parse time and zsh parses a whole `if ... fi` block before running any of
# it, so this has to sit outside the block below -- otherwise a stale alias in
# a long-lived shell turns those function definitions into a parse error the
# next time this file is sourced.
unalias ssh icat 2>/dev/null

if command -v kitten >/dev/null 2>&1; then

  _in_kitty() {
    [[ -t 0 && -t 1 ]] || return 1
    if [[ -n "$TMUX" ]]; then
      [[ "$(tmux display-message -p '#{client_termname}' 2>/dev/null)" == xterm-kitty ]]
    else
      [[ "$TERM" == xterm-kitty ]]
    fi
  }

  ssh() {
    # Control-master, forward-only and proxy invocations never open a remote
    # shell, so the kitten has nothing to set up -- hand those to real ssh.
    local arg
    for arg in "$@"; do
      case "$arg" in
        -N|-O|-W|-Q|-G|-f) command ssh "$@"; return ;;
      esac
    done

    if _in_kitty; then
      kitten ssh "$@"
    else
      command ssh "$@"
    fi
  }

  icat() {
    if _in_kitty; then
      kitten icat "$@"
    else
      print -u2 "icat: not attached to a kitty terminal"
      return 1
    fi
  }
fi

# ---------------------------------------------------------------------------
# Theme
# ---------------------------------------------------------------------------
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------------------------------------------------------------------------
# Run fastfetch after P10K completes (login shells only)
# ---------------------------------------------------------------------------
if [[ -o login ]]; then
  function run_fastfetch_once() {
    TERM=xterm-256color fastfetch
    unfunction run_fastfetch_once
    precmd_functions=(${precmd_functions:#run_fastfetch_once})
  }
  precmd_functions+=(run_fastfetch_once)
fi

# ---------------------------------------------------------------------------
# Syntax highlighting (MUST be last)
# ---------------------------------------------------------------------------
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm
export PNPM_HOME="/Users/williamphong/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
