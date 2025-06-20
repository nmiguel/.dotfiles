#!/bin/bash
set -euo pipefail

wallpaper_dir="$HOME/Pictures/wallpapers"
themes_dir="$HOME/.config/rofi/themes"
output_image="$wallpaper_dir/.wallpaper_current"

# Transition config (only relevant if using swww, but we don’t use it here)
FPS=60
TYPE="any"
DURATION=3
BEZIER="0.4,0.2,0.4,1.0"
SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"

# Get list of wallpapers
mapfile -t PICS < <(find "$wallpaper_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) | sort)

# Handle empty list
if [ ${#PICS[@]} -eq 0 ]; then
  echo "No images found in $wallpaper_dir"
  exit 1
fi

# Generate random selection
randomNumber=$(( ($(date +%s) + RANDOM) + $$ ))
randomPicture="${PICS[$(( randomNumber % ${#PICS[@]} ))]}"
randomChoice="[${#PICS[@]}] Random"

# Build rofi input
menu() {
  printf "$randomChoice\n"
  for img in "${PICS[@]}"; do
    if [[ -z $(echo "$img" | grep .gif$) ]]; then
      printf "$(basename "${img}" | cut -d. -f1)\x00icon\x1f${img}\n"
    else
      printf "$(basename "${img}")\n"
    fi
  done
}

# Display rofi
choice=$(menu | rofi -i -dmenu -theme "${themes_dir}/wallpaper-select.rasi")

# Exit on cancel
[[ -z "$choice" ]] && exit 0

# Resolve selection
if [[ "$choice" = "$randomChoice" ]]; then
  selected="$randomPicture"
else
  selected=""
  for img in "${PICS[@]}"; do
    name=$(basename "$img" | cut -d. -f1)
    if [[ "$choice" == "$name" ]]; then
      selected="$img"
      break
    fi
  done
fi

# If selected file not found
[[ -z "$selected" ]] && {
  echo "Image not found."
  exit 1
}

# Ensure wallpaper_dir exists
mkdir -p "$wallpaper_dir"

# Copy to .wallpaper_current
rm -f "$output_image"
cp "$selected" "$output_image"

# Apply wallpaper and generate palette
hyprctl hyprpaper reload ,"$output_image"
wallust run "$output_image" -s
swaync-client -rs

