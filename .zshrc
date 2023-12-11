# Exports
export TERM="xterm-256color"
export TERMINAL="alacritty"
export BROWSER="firefox"
export EDITOR="vim"
export VISUAL="vim"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export WINIT_X11_SCALE_FACTOR=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MANPAGER="nvim +Man!" # Nvim as manpager
export XKB_DEFAULT_LAYOUT="es"
export XKB_DEFAULT_VARIANT="qwerty"

# If not running interactively or it's a login shell, don't do anything
[[ $- != *i* || -o login ]] && return

# ssh-add and ssh require an environment variable to know how
# to talk to the ssh agent
SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"
if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
    eval `$SSHAGENT $SSHAGENTARGS` > /dev/null 2>&1
    trap "kill $SSH_AGENT_PID" 0
fi

# Paths
if [ -d "$HOME/.bin" ]; then 
  export PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then 
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/Applications" ]; then
  export PATH="$HOME/Applications:$PATH"
fi

# Setting other enviroment variables
if [ -z "$XDG_CONFIG_HOME" ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z "$XDG_DATA_HOME" ]; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z "$XDG_CACHE_HOME" ]; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi

export XMONAD_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xmonad"
export XMONAD_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/xmonad"
export XMONAD_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/xmonad"

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to the oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable marking untracked files under VCS as dirty.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# ZSH Plugins
plugins=(
  git
  zsh-autosuggestions
)

# Start Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Aliases
alias git-config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias cat="bat"
alias vim="nvim"
alias ls="lsd"
alias logout="loginctl terminate-user $(whoami)"

# Node Options
export NODE_OPTIONS=--max_old_space_size=4096

# Start PowerLevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# NVM
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Elastic Beanstalk CLI
export PATH="$HOME/.ebcli-virtual-env/executables:$PATH"

# JetBrains Toolbox
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
