[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
exec $HOME/.cache/xmonad/xmonad-x86_64-linux
