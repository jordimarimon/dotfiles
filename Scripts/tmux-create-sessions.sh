#!/bin/bash


# Path of each session
declare -A PATHS
PATHS[0]="$HOME/Hooba/erp-frontend"
PATHS[1]="$HOME/Hooba/erp-web"
PATHS[2]="$HOME/Hooba/erp-import-app"
PATHS[3]="$HOME/Hooba/erp-fixtures"
PATHS[4]="$HOME/Hooba/erp-console-api"
PATHS[5]="$HOME/Hooba/erp-db-changes"

# Loop through each session and creates it
for INDEX in "${!PATHS[@]}"; do
    SESSION_PATH="${PATHS[$INDEX]}"
    SESSION_NAME=$(basename "$SESSION_PATH" | tr . _)

    # Check if the session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
	continue
    fi

    ~/Scripts/tmux-create-session.sh "$SESSION_PATH"
done

