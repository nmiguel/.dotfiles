#!/bin/bash

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

grep_args=()
dry_run="0"

while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--dry" ]]; then
        echo "DRY RUN ENABLED"
        dry_run="1"
    else
        echo "ARG: \"$1\""
        grep_args+=("$1")
    fi
    shift
done

log() {
    if [[ $dry_run == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

scripts=$(find "$source_dir/scripts" -mindepth 1 -maxdepth 1 -type f -executable)

for s in $scripts; do
    script_name=$(basename "$s")

    # Apply grep filters only if there are grep args
    if [[ ${#grep_args[@]} -gt 0 ]]; then
        matched=0
        for pattern in "${grep_args[@]}"; do
            if echo "$script_name" | grep -q "$pattern"; then
                matched=1
                break
            fi
        done
        if [[ $matched -eq 0 ]]; then
            if  [[ $dry_run == "1" ]]; then
                log "filtered out: $s"
            fi
            continue
        fi
    fi

    log "running script: $s"

    if [[ $dry_run == "0" ]]; then
        "$s"
    fi
done

