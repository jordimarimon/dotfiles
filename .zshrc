# If not running interactively or it's a login shell, don't do anything
[[ $- != *i* || -o login ]] && return

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add Powerlevel10k
# https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#zinit
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Completion-System
autoload -Uz compinit && compinit

# Execute "compdef" calls that plugins did – they were recorded,
# so that compinit can be called later (compinit provides
# the compdef function, so it must be ran before issuing the
# taken-over compdefs with zicdreplay)
zinit cdreplay -q

# Keybindings
bindkey -e # Emacs bindings (for vim it would be "bindkey -v")
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Carapace
export CARAPACE_BRIDGES="zsh"
source <(carapace _carapace)

# ssh-add and ssh require an environment variable to know how
# to talk to the ssh agent
SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"
if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
    eval `$SSHAGENT $SSHAGENTARGS` > /dev/null 2>&1
    trap "kill $SSH_AGENT_PID" 0
fi

# Export helper functions
. $HOME/Scripts/utils.sh

# Aliases
alias gc='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias g="git"
alias cat="bat"
alias ls="lsd"
alias logout="loginctl terminate-user $(whoami)"
alias trash="gio trash"
alias browsepkgs="pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
alias foreignpkgs="yay -Qm"
alias info='info --vi-keys'
alias tmuxstart="$HOME/Scripts/tmux-create-sessions.sh"
alias tmuxcreate="$HOME/Scripts/tmux-create-session.sh"

