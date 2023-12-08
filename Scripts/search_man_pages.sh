#!/bin/bash


man -k . | awk '{$3="-"; print $0}' | rofi -dmenu -l 20 -i -p 'Search for:' | awk '{print $2, $1}' | tr -d '()' | xargs alacritty -e man

