#!/bin/bash

function take_region() {
    output="$(slurp -d)"

    if [ -z "$output" ]; then
        notify-send "No region selected"
        exit 1
    fi

    grim -g "$output" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify "Screenshot of the region taken" -t 1000
}

function take_fullscreen() {
    grim - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify "Screenshot of whole screen taken" -t 1000
}

commands=(\
    "Region"\ 
    "Fullscreen"
);

IFS=$'\n';
choice=$(echo "${commands[*]}" | fuzzel --dmenu -i);
IFS=' ';

if [ -z "$choice" ]; then
    exit 0;
fi

index=""
for i in "${!commands[@]}"; do
    if [[ "${commands[$i]}" = "${choice}" ]]; then
        index="$i"
    fi
done

case "$index" in
    0)
        take_region;
        ;;
    1)
        take_fullscreen;
        ;;
    *)
        notify-send "Unknown option selected";
        ;;
esac
