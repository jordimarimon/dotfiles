#!/bin/bash


# FIXME: Migrate to wayland
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

# FIXME: Migrate to wayland
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

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"

	yazi "$@" --cwd-file="$tmp"

	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd "$cwd"
	fi

	rm -f -- "$tmp"
}
