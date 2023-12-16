# Useful environment variables
export TERM="xterm-256color"
export TERMINAL="alacritty"
export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export WINIT_X11_SCALE_FACTOR=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MANPAGER="nvim +Man!" # Nvim as manpager
export XKB_DEFAULT_LAYOUT="es"
export XKB_DEFAULT_VARIANT="qwerty"
export BAT_THEME="Catppuccin-latte"
export NODE_OPTIONS=--max_old_space_size=4096

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

# JetBrains Toolbox
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ghcup-env
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
