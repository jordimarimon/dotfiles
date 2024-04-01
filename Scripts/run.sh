#!/bin/bash


commands=(\
	"Open an application"\ 
	"Open project with JetBrains IDE"\ 
	"Open project with Neovim"\ 
	"Open PDF"\ 
	"Open XLSX"\ 
);

IFS=$'\n';
choice=$(echo "${commands[*]}" | rofi -dmenu -i -l 20 -format 'i' -p "Run: ");
IFS=' ';

case "$choice" in
	0)
		rofi -show drun;
		;;
	1)
		alacritty -e zsh -i -c open_project_jetbrains;
		;;
	2)
		alacritty -e zsh -i -c open_project_neovim;
		;;
	3)
		alacritty -e zsh -i -c open_pdf;
		;;
	4)
		alacritty -e zsh -i -c open_xlsx;
		;;
	*)
		notify-send "Unknown option selected";
		;;
esac

