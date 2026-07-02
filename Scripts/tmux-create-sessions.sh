#!/bin/bash


# Path of each session
PATHS=(
    "$HOME/Hooba/apps"
    "$HOME/Hooba/web-components"
    "$HOME/Hooba/console-import-app"
    "$HOME/Hooba/apps-fixtures"
    "$HOME/Hooba/erp-console-api"
    "$HOME/Hooba/erp-db-changes"
    "$HOME/Hooba/erp-infrastructure"
    "$HOME/Hooba/web-api"
    "$HOME/Hooba/web-fonts"
)

# Loop through each session and creates it
for SESSION_PATH in "${PATHS[@]}"; do
    SESSION_NAME=$(basename "$SESSION_PATH" | tr . _)

    # Check if the session already exists
    if tmux has-session -t "=$SESSION_NAME" 2>/dev/null; then
	continue
    fi

    ~/Scripts/tmux-create-session.sh "$SESSION_PATH"
done

