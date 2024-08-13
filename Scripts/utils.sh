#!/bin/bash


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
