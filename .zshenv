# Useful environment variables
export TERM="xterm-256color"
export TERMINAL="foot"
export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export WINIT_X11_SCALE_FACTOR=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MANPAGER="nvim +Man!" # Nvim as manpager
export XKB_DEFAULT_LAYOUT="es"
export NODE_OPTIONS=--max_old_space_size=4096
export HISTSIZE=500
export HISTFILESIZE=$HISTSIZE
export SAVEHIST=$HISTSIZE
export HISTFILE=~/.zsh_history
export HISTDUP=erase
export BAT_THEME="GitHub"
export FZF_DEFAULT_OPTS=" \
--color=light,bg+:#ffffff,bg:-1,spinner:#000000,hl:#000000 \
--color=fg:-1,header:#000000,info:#000000,pointer:#000000 \
--color=marker:#000000,fg+:#000000,prompt:#000000,hl+:#000000"

# Paths
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib64/:$LD_LIBRARY_PATH

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/rc"

if [ -d "$HOME/.bin" ]; then 
  export PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then 
  export PATH="$HOME/.local/bin:$PATH"
fi

# XDG enviroment variables
if [ -z "$XDG_CONFIG_HOME" ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [ -z "$XDG_DATA_HOME" ]; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi

if [ -z "$XDG_CACHE_HOME" ]; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi

if [ -z "$XDG_STATE_HOME" ]; then
    export XDG_STATE_HOME="$HOME/.local/state"
fi

if [ -z "$XDG_DATA_DIRS" ]; then
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

# Xmonad enviroment variables
export XMONAD_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xmonad"
export XMONAD_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/xmonad"
export XMONAD_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/xmonad"

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

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ghcup
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# Rust
. "$HOME/.cargo/env"
