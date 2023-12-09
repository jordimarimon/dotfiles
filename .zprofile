if [[ "$(tty)" = "/dev/tty1" ]]; then
	exec startx >& ~/.xsession-errors
fi

