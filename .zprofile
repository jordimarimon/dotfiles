if [[ "$(tty)" = "/dev/tty1" ]]; then
	# exec startx >& ~/.xsession-errors
	exec dbus-run-session Hyprland >& ~/hyprland.logs.txt
fi

