#!/bin/bash


function open_project_neovim() {
	personal_projects=($(ls -d "$HOME/Projects/"*));
	company_projects=($(ls -d "$HOME/Interactiu/"*));
	all_projects=("${personal_projects[@]}" "${company_projects[@]}");

	IFS=$'\n';
	project=$(printf '%q' "`echo \"${all_projects[*]}\" | fzf`");
	IFS=' ';

	if [[ ! -z "$project" && "$project" != "''" ]]; then
		cd "$project";
		nvim "$project";
	fi
}

function open_pdf() {
	window_id=$(xdo id);
	file=$(printf '%q' "`find -type f -name \"*.pdf\" | fzf`");

	if [[ "$file" != *.pdf ]]; then
		exit 0;
	fi

	xdo hide $window_id;
	bash -i -c "zathura $file > /dev/null 2>&1; exit 0";
	xdo show $window_id;
}

function open_xlsx() {
	window_id=$(xdo id);
	file=$(printf '%q' "`find -type f -name \"*.xlsx\" | fzf`");

	if [[ "$file" != *.xlsx ]]; then
		exit 0;
	fi

	xdo hide $window_id;
	bash -i -c "libreoffice --calc $file > /dev/null 2>&1; exit 0";
	xdo show $window_id;
}

function open_notes() {
	notes=($(ls "$HOME/Notes/"));

	IFS=$'\n';
	note=$(printf '%q' "`echo \"${notes[*]}\" | fzf`");
	IFS=' ';

	if [[ ! -z "$note" && "$note" != "''" ]]; then
		nvim "$HOME/Notes/$note";
	fi
}
