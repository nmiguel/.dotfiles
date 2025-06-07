#!/bin/bash

# Read monitor name, active workspace, and focus flag into arrays
monitors=() workspaces=() focused=()
while IFS= read -r line; do
  case "$line" in
    Monitor*)
      monitors+=("$(awk '{print $2}' <<<"$line")") ;;
    *"active workspace:"*)
      workspaces+=("$(awk '{print $3}' <<<"$line" | tr -d '()')") ;;
    *"focused:"*)
      focused+=("$(awk '{print $2}' <<<"$line")") ;;
  esac
done < <(hyprctl monitors)

# Ensure exactly two monitors were found
if [ "${#monitors[@]}" -ne 2 ] || [ "${#workspaces[@]}" -ne 2 ] || [ "${#focused[@]}" -ne 2 ]; then
  echo "Error: Expected 2 monitors; got ${#monitors[@]}. Aborting."
  exit 1
fi

# Decide swap order: first move the workspace on the focused monitor
if [ "${focused[0]}" = "yes" ]; then
    first_ws="${workspaces[1]}"
    first_mon="${monitors[0]}"
    second_ws="${workspaces[0]}"
    second_mon="${monitors[1]}"
else
    first_ws="${workspaces[0]}"
    first_mon="${monitors[1]}"
    second_ws="${workspaces[1]}"
    second_mon="${monitors[0]}"
fi

# Perform both moves in one batch (focused one first)
hyprctl --batch \
  "dispatch moveworkspacetomonitor $first_ws $first_mon; \
   dispatch moveworkspacetomonitor $second_ws $second_mon"

