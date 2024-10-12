#!/bin/bash


SESSION_NAME="interactiu"

FRONTEND_PATH="$HOME/Interactiu/erp-frontend"
WEB_PATH="$HOME/Interactiu/erp-web"
IWC_PATH="$HOME/Interactiu/interactiu-web-components"
IMPORT_PATH="$HOME/Interactiu/erp-import-app"
API_PATH="$HOME/Interactiu/erp-console-api"

# Check if the session already exists
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # Create a new session
    tmux new-session -d -s $SESSION_NAME -c $FRONTEND_PATH -n "frontend"

    # Create additional windows
    tmux new-window -c $WEB_PATH -n "web"
    tmux new-window -c $IWC_PATH -n "iwc"
    tmux new-window -c $IMPORT_PATH -n "import"
    tmux new-window -c $API_PATH -n "api"

    # Split the first window into two panes (vertical split)
    tmux split-window -v -c $FRONTEND_PATH -t $SESSION_NAME:0

    # Split the second window into two panes (vertical split)
    tmux split-window -v -c $WEB_PATH -t $SESSION_NAME:1

    # Select the first window to set focus
    tmux select-window -t $SESSION_NAME:0

    # Attach to the session
    tmux attach-session -t $SESSION_NAME
else
    # Attach to the existing session
    tmux attach-session -t $SESSION_NAME
fi
