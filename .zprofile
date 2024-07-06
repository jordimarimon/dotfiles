if [[ "$(tty)" = "/dev/tty1" ]]; then
	# exec startx >& ~/.xsession-errors
	Hyprland >& ~/hyprland.logs.txt
fi

