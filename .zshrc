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

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Export helper functions
. $HOME/Scripts/utils.sh

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
alias ls="lsd"
alias logout="loginctl terminate-user $(whoami)"
alias trash="gio trash"

# Start PowerLevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

