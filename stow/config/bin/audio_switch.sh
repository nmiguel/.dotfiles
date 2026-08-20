#!/bin/sh

current_sink=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | awk -F'"' '/node.name =/ { print $2; exit }')

case "$current_sink" in
    virtual_headphones_sink) next_sink=virtual_speakers_sink ;;
    *) next_sink=virtual_headphones_sink ;;
esac

next_id=$(wpctl status -n | awk -v name="$next_sink" '
    index($0, name) && match($0, /[0-9]+\./) {
        print substr($0, RSTART, RLENGTH - 1)
        exit
    }
')

if [ -z "$next_id" ]; then
    printf 'Audio sink %s is unavailable\n' "$next_sink" >&2
    exit 1
fi

printf 'Switching from %s to %s\n' "$current_sink" "$next_sink"
exec wpctl set-default "$next_id"
