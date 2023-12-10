#!/bin/bash


personal_projects=($(ls -d "$HOME/Projects/"*))
company_projects=($(ls -d "$HOME/Interactiu/"*))
all_projects=("${personal_projects[@]}" "${company_projects[@]}")

IFS=$'\n' 
choice=$(echo "${all_projects[*]}" | rofi -dmenu -i -l 20 -p "Projects: ")
IFS=' '

if [[ ! -z "$choice" ]]; then
	"$HOME"/.local/share/JetBrains/Toolbox/apps/phpstorm/bin/phpstorm.sh "$choice"
fi

