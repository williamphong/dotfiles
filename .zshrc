# Powerlevel10k instant prompt
if [[ -o login ]]; then
  function run_fastfetch_once() {
    TERM=xterm-256color fastfetch
    unfunction run_fastfetch_once
    precmd_functions=(${precmd_functions:#run_fastfetch_once})
  }
  precmd_functions+=(run_fastfetch_once)
fi
# Path & environment variables
export PATH="/Users/williamphong/.pixi/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/mysql/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export CLICOLOR=1
export SPICETIFY_INSTALL="$HOME/.spicetify"
export PATH="$PATH:$SPICETIFY_INSTALL"

# Initialize completion system
autoload -Uz compinit && compinit

# Aliases
alias ls="lsd"
alias ll="lsd -lG"
alias ssh="kitten ssh"
alias icat="kitten icat"
alias vim="nvim"
alias vi="nvim"
alias cd="z"
# Tell zsh to use the same completion for kitten as it does for ssh
compdef kitten=ssh

# Themes & plugins
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Tool initialization
eval "$(fnm env --use-on-cd)"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# Pixi auto-activation
autoload -U add-zsh-hook
load_pixi_env() {
  if [[ -f "pixi.toml" ]]; then
    if [[ "$PIXI_ACTIVE_PROJECT" != "$(pwd)" ]]; then
      export PIXI_ACTIVE_PROJECT="$(pwd)"
      eval "$(pixi shell-hook)"
    fi
  elif [[ -n "$PIXI_ACTIVE_PROJECT" ]]; then
    unset PIXI_ACTIVE_PROJECT
  fi
}
add-zsh-hook chpwd load_pixi_env
load_pixi_env

# Run fastfetch after P10K completes (login shells only)
if [[ -o login ]]; then
  function run_fastfetch_once() {
    fastfetch
    unfunction run_fastfetch_once
    precmd_functions=(${precmd_functions:#run_fastfetch_once})
  }
  precmd_functions+=(run_fastfetch_once)
fi

# bun completions
[ -s "/Users/williamphong/.bun/_bun" ] && source "/Users/williamphong/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/williamphong/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# zoxide initialization
eval "$(zoxide init zsh)"
