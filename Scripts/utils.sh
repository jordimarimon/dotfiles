#!/bin/bash


function open_notes() {
    notes=($(ls "$HOME/Notes/"));

    IFS=$'\n';
    note=$(printf '%q' "`echo \"${notes[*]}\" | fzf`");
    IFS=' ';

    if [[ ! -z "$note" && "$note" != "''" ]]; then
        nvim "$HOME/Notes/$note" -c "cd $HOME/Notes";
    fi
}
