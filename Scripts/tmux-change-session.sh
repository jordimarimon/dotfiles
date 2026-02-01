#!/usr/bin/env bash

function switch_to() {
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$1"
    else
        tmux switch-client -t "$1"
    fi
}

function has_session() {
    tmux list-sessions | grep -q "^$1:"
}

function tmux_session_manager() {
    tmux_running=$(pgrep tmux)

    if [[ -z $tmux_running ]]; then
        notify-send "No tmux sessions are running.";
        return
    fi

    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(tmux list-sessions -F "#{session_name}" | fuzzel --dmenu -i)
    fi

    if [[ -z $selected ]]; then
        notify-send "No session selected.";
        return
    fi

    if ! has_session "$selected"; then
        notify-send "Session '$selected' does not exist.";
        return
    fi

    switch_to "$selected"
}

tmux_session_manager "$@"
