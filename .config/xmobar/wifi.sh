#!/bin/bash

TYPES=($(nmcli device show | grep "GENERAL.TYPE" | awk '{print $2}'))
STATES=($(nmcli device show | grep "GENERAL.STATE" | awk '{print $3}'))

for ((i = 0; i < "${#TYPES[@]}"; i++)); do
    if [[ ${STATES[$i]} = "(connected)" ]]; then
        if [[ ${TYPES[$i]} == *"wifi"* ]]; then
            echo "<fc=#929AAD><fn=5>直</fn></fc>"
        else
            echo "<fc=#929AAD><fn=4>ﯱ</fn></fc>"
        fi
    fi
done

echo "<fc=#929AAD><fn=4>ﯱ</fn></fc>"
