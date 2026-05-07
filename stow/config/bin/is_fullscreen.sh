#!/bin/bash

# Get the ID of the currently focused workspace
focused_ws=$(hyprctl -j monitors | jq -r '.[] | select(.focused == true).activeWorkspace.id')

# Guard against null
if [ -z "$focused_ws" ] || [ "$focused_ws" = "null" ]; then
    exit 0
fi

# Check if any fullscreen client is on the focused workspace
fullscreen_count=$(hyprctl -j clients | jq --arg ws "$focused_ws" '[.[] | select(.fullscreen == 1 and (.workspace.id|tostring) == $ws)] | length')

if [ "$fullscreen_count" -gt 0 ]; then
    echo " "
fi

