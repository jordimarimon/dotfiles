#!/usr/bin/env bash


switch_to() {
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$1"
    else
        tmux switch-client -t "$1"
    fi
}

has_session() {
    tmux list-sessions | grep -q "^$1:"
}

tmux_session_manager() {
    tmux_running=$(pgrep tmux)

    if [[ -z $tmux_running ]]; then
        echo "No tmux sessions are running."
        return
    fi

    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(tmux list-sessions -F "#{session_name}" | fzf --height 40% --reverse --border --prompt "Select a session: ")
    fi

    if [[ -z $selected ]]; then
        echo "No session selected."
        return
    fi

    if ! has_session "$selected"; then
        echo "Session '$selected' does not exist."
        return
    fi

    switch_to "$selected"
}

tmux_session_manager "$@"
