#!/bin/bash


if [[ -z $1 ]]; then
    echo "Expected as argument the path of the project."
    exit 1
fi

SESSION_PATH=$1
SESSION_NAME=$(basename "$SESSION_PATH" | tr . _)
SESSION_ATTACH=0

if [[ $2 == "-a" ]]; then
    SESSION_ATTACH=1
fi

# Check if the session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    if [[ $SESSION_ATTACH -eq 1 ]]; then
        tmux attach-session -t "$SESSION_NAME"
    else
        echo "Session '$SESSION_NAME' already exists. Use '-a' to attach."
    fi
    exit 0
fi

# Create a new session (the first window is for neovim)
tmux new-session -d -s $SESSION_NAME -c "$SESSION_PATH" -n "editor"

# Open neovim in the first window
tmux send-keys -t "$SESSION_NAME:1" "nvim ." C-m

# Create a second window in the same session for the shell
tmux new-window -c "$SESSION_PATH" -n "shell"

# Set focus to the first window
tmux select-window -t $SESSION_NAME:1

# Attach to the session created
if [[ $SESSION_ATTACH -eq 1 ]]; then
    tmux attach-session -t "$SESSION_NAME"
fi
