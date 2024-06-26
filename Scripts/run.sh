#!/bin/bash


commands=(\
	"Open Application"\ 
	"Open Project"\ 
	"Open PDF"\ 
	"Open XLSX"\ 
	"Open Notes"
);

IFS=$'\n';
choice=$(echo "${commands[*]}" | rofi -dmenu -i -l 20 -format 'i' -p "Run: ");
IFS=' ';

if [ -z "$choice" ]; then
	exit 0;
fi

case "$choice" in
	0)
		rofi -show drun;
		;;
	1)
		alacritty -e zsh -i -c open_project_neovim;
		;;
	2)
		alacritty -e zsh -i -c open_pdf;
		;;
	3)
		alacritty -e zsh -i -c open_xlsx;
		;;
	4)
		alacritty -e zsh -i -c open_notes;
		;;
	*)
		notify-send "Unknown option selected";
		;;
esac

