#!/bin/bash

STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

MUTE=$(echo "$STATUS" | awk -F ': ' '{print $2}' | awk -F ' ' '{print $2}')

VOLUME=$(echo "$STATUS" | awk -F ': ' '{print $2}' | awk -F ' ' '{print $1}')
VOLUME="$(echo "$VOLUME * 100" | bc -l | awk -F '.' '{print $1}')"

if [ "$MUTE" = "[MUTED]" ]; then
    echo "<fc=#696B71><fn=3></fn></fc> "
elif [ "$VOLUME" -eq 0 ]; then
    echo "<fc=#696B71><fn=3></fn></fc>   "
elif [ "$VOLUME" -lt 77 ]; then
    echo "<fc=#DFDFDF><fn=3></fn></fc>  "
else
    echo "<fc=#DFDFDF><fn=3></fn></fc>"
fi
