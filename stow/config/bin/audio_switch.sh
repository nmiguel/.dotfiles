#!/bin/bash

speakers=`pactl list short sinks | grep virtual_headphones_sink | awk 'BEGIN {FS="\t"}; {print $2}'`
headphones=`pactl list short sinks | grep virtual_speakers_sink | awk 'BEGIN {FS="\t"}; {print $2}'`

current_sink=`pactl get-default-sink`

echo "Audio switcher :: current audio sink: $current_sink"

next_sink=$speakers
if [[ "$current_sink" == "$speakers" ]]; then
    next_sink=$headphones
fi

echo "Audio switcher :: switching to: $next_sink"

exec pactl set-default-sink $next_sink

echo "Audio switcher :: done"
