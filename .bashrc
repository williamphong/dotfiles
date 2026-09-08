# ~/.bashrc: interactive bash configuration.
#
# Mirrors ~/.zshrc (the macOS daily driver) so that a shell on a Linux box
# behaves the same way: same history policy, same aliases, same tools.
#
# kitty copies this file to remote hosts on connect -- see the copy line in
# .config/kitty/ssh.conf -- so it lands on machines that may have none of these
# tools installed, and on machines whose defaults we do not control. Every
# block below is therefore guarded, and the file must degrade to a plain,
# working bash shell when nothing optional is present. Nothing here may print
# to stdout unconditionally.

# Must stay first: scp, rsync and git-over-ssh start a non-interactive shell
# and break if this file writes anything to stdout.
case $- in
*i*) ;;
*) return ;;
esac

# ---------------------------------------------------------------------------
# ble.sh
#
# Sourced first, with --noattach, so that everything below -- starship
# especially -- can set PS1 before ble.sh captures the prompt. The matching
# ble-attach is the last line of this file; the two are a pair.
# ---------------------------------------------------------------------------
if [[ -f "$HOME/.local/share/blesh/ble.sh" ]]; then
  source "$HOME/.local/share/blesh/ble.sh" --noattach
fi

# ---------------------------------------------------------------------------
# Path & environment variables
# ---------------------------------------------------------------------------
# Prepend without creating duplicates on every re-source.
prepend_path() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) [[ -d "$1" ]] && PATH="$1:$PATH" ;;
  esac
}
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.pixi/bin"
export PATH

# nvim is the editor when it exists; on a bare server fall back rather than
# leaving EDITOR pointing at something that is not installed.
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi
export VISUAL="$EDITOR"

# openspec
export OPENSPEC_TELEMETRY=0

# ---------------------------------------------------------------------------
# History
#
# Bash equivalents of the zsh setopts in .zshrc. Sizes match so that history
# behaves identically on both machines.
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=100000

# ignorespace: a leading space keeps a command out of history.
# ignoredups + erasedups: drop older duplicates of a repeated command.
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '

shopt -s histappend  # don't clobber the file on exit
shopt -s cmdhist     # keep a multi-line command as one history entry
shopt -s checkwinsize

# zsh's SHARE_HISTORY, approximated: append this shell's new lines, then read
# back any lines other shells appended. `history -n` reads only what is new
# since the last read -- the more common `history -c; history -r` idiom clears
# and re-reads the entire file on every single prompt, which is slow once the
# file is large and worse over a network home directory. Set before starship,
# which preserves an existing PROMPT_COMMAND when it prepends its own.
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ---------------------------------------------------------------------------
# Completion system
#
# Must run BEFORE anything that registers a completion (fnm, zoxide, direnv),
# because `complete` needs bash-completion's helpers to already be loaded.
# ---------------------------------------------------------------------------
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

# ---------------------------------------------------------------------------
# Tool initialization
# ---------------------------------------------------------------------------
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"

# zoxide (replaces cd with smart version, keeps cd -, cd .. etc.)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd cd)"

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ---------------------------------------------------------------------------
# direnv
#
# Same role as on macOS: snapshots the environment on entry to a project and
# restores it on exit, instead of prepending to PATH and never cleaning up.
#
# Per pixi project, create a .envrc at the project root containing:
#
#     watch_file pixi.lock
#     eval "$(pixi shell-hook)"
#
# then run `direnv allow` once in that directory.
# ---------------------------------------------------------------------------
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# ---------------------------------------------------------------------------
# SSH agent
#
# Deliberately does NOT start an agent or load a key. The private key stays on
# the Mac; `ForwardAgent yes` on the client side makes sshd set SSH_AUTH_SOCK
# here on its own, so git over ssh works with no key ever landing on this box.
#
# The one thing that needs help is tmux. SSH_AUTH_SOCK points at a per-connection
# socket that dies when that ssh session ends, but the tmux server outlives it,
# so panes reattached from a later connection inherit a dead path. Pinning a
# stable symlink to the live socket, and exporting that instead, keeps
# long-running panes working across reconnects.
# ---------------------------------------------------------------------------
if [[ -n "${SSH_AUTH_SOCK-}" && -S "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent.sock" ]]; then
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent.sock"
fi
[[ -S "$HOME/.ssh/agent.sock" ]] && export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
if command -v lsd >/dev/null 2>&1; then
  alias ls="lsd"
  alias ll="lsd -lG"
else
  # Plain coreutils fallback, plus the colour setup lsd would have handled.
  if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r "$HOME/.dircolors" ]]; then
      eval "$(dircolors -b "$HOME/.dircolors")"
    else
      eval "$(dircolors -b)"
    fi
  fi
  alias ls="ls --color=auto"
  alias ll="ls -alF"
fi

alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

if command -v nvim >/dev/null 2>&1; then
  alias vim="nvim"
  alias vi="nvim"
fi

# make less friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# The persistence hook. On a remote host this file itself is re-copied by
# kitten ssh on every connection, so edits to it there are lost; ~/.bash_aliases
# is never copied and is the place for per-server changes.
[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

# ---------------------------------------------------------------------------
# Theme
#
# starship fills the role powerlevel10k plays on macOS. Without it, fall back
# to a readable coloured prompt rather than bash's bare default.
# ---------------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# ---------------------------------------------------------------------------
# Run fastfetch on login shells only
#
# Not every interactive shell: that would fire on every new tmux pane and every
# subshell. TERM is pinned because fastfetch picks an image backend from it and
# the kitty backend garbles output when drawn inside tmux.
# ---------------------------------------------------------------------------
if shopt -q login_shell && command -v fastfetch >/dev/null 2>&1; then
  TERM=xterm-256color fastfetch
fi

# ---------------------------------------------------------------------------
# ble.sh: attach (MUST be last)
#
# Runs after starship has set PS1 above. The bleopt settings have to follow the
# source at the top of the file and can only take effect once ble.sh is loaded.
# ---------------------------------------------------------------------------
if [[ -n "${BLE_VERSION-}" ]]; then
  # transient prompt: collapse past prompts to just the character module
  bleopt prompt_ps1_final='$(starship module character)'
  bleopt prompt_ps1_transient=always

  # no right-hand prompt
  bleopt prompt_rps1_final=' '
  bleopt prompt_rps1=' '
  bleopt prompt_rps1_transient=' '

  bleopt complete_auto_complete=1     # automatic completion
  bleopt complete_auto_history=       # disable history completion
  bleopt highlight_syntax=1           # syntax highlighting
  bleopt complete_menu_color_match=on # colour match in completion menu

  ble-attach
fi
