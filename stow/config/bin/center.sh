#!/usr/bin/env bash

WIDTH=40
HEIGHT=24

mapfile -t lines

# Determine content dimensions
maxw=0
for line in "${lines[@]}"; do
    (( ${#line} > maxw )) && maxw=${#line}
done

content_h=${#lines[@]}

# Compute padding
pad_top=$(( (HEIGHT - content_h) / 2 ))
pad_left=$(( (WIDTH - maxw) / 2 ))

(( pad_top < 0 )) && pad_top=0
(( pad_left < 0 )) && pad_left=0

# Top padding
for ((i=0; i<pad_top; i++)); do
    echo
done

# Print centered lines
for line in "${lines[@]}"; do
    printf "%*s%s\n" "$pad_left" "" "$line"
done
