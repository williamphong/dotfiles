export PATH="/opt/homebrew/bin/:$PATH"

# Enable fastfetch
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export SPICETIFY_INSTALL="/Users/isti/.spicetify"
export PATH="$PATH:/Users/isti/.spicetify"export PATH=$PATH:/Users/williamphong/.SPICETIFY_INSTALL
export PATH=/opt/homebrew/bin:$PATH
export NVM_DIR="$HOME/.nvm"
export PATH=${PATH}:/usr/local/mysql/bin/
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/opt/homebrew/sbin:$PATH" 

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/williamphong/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/williamphong/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/williamphong/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/williamphong/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Make nvim default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Enable p10k and zsh-syntax-highlighting
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



