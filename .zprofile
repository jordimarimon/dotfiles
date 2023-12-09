if [[ "$(tty)" = "/dev/tty1" ]]; then
	exec startx >& ~/.xsession-errors
fi



# Added by Toolbox App
export PATH="$PATH:/home/jmarimon/.local/share/JetBrains/Toolbox/scripts"

