#!/usr/bin/env bash
ws=$(hyprctl activeworkspace -j | jq -r .id)

if [ "$ws" -eq 5 ]; then
    exit 0
fi

hyprctl dispatch movecurrentworkspacetomonitor +1

