#!/usr/bin/bash

class="$1"
running=$(hyprctl -j clients | jq -r --arg class "$class" '.[] | select(.class == $class) | .workspace.id')

if [[ -n "$running" ]]; then
    hyprctl dispatch workspace "$running"
fi

