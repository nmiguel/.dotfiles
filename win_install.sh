#!/bin/bash

# Set WINHOME custom variable
export WINHOME="$(
  wslpath "$(
    cmd.exe /C "echo %USERPROFILE%" 2>/dev/null \
    | tr -d '\r'
  )"
)"

echo "Syncing with windows config"
rsync -av --exclude='**/.git/**' winhome/ "$WINHOME"/
