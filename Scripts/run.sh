#!/bin/bash


commands=(\
	"Open Application"\ 
	"Open Notes"
);

IFS=$'\n';
choice=$(echo "${commands[*]}" | wofi --dmenu -i);
IFS=' ';

if [ -z "$choice" ]; then
	exit 0;
fi

index=""
for i in "${!commands[@]}"; do
	if [[ "${commands[$i]}" = "${choice}" ]]; then
		index="$i"
	fi
done

case "$index" in
	0)
		wofi --show drun;
		;;
	1)
		foot zsh -i -c open_notes;
		;;
	*)
		notify-send "Unknown option selected";
		;;
esac

