[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
setxkbmap -option caps:escape
exec $HOME/.cache/xmonad/xmonad-x86_64-linux
