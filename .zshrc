# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add binaries to PATH
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$PATH

# asdf
. $HOME/.asdf/asdf.sh

# Z-Shell Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Aliases
alias cat="bat --style=auto"
alias ls="exa --icons"

# Zoxide Initialization
eval "$(zoxide init zsh)"

# Git completions
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

# Android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Poetry completions
fpath+=~/.zfunc
autoload -Uz compinit && compinit

