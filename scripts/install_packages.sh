#!/bin/bash


script_dir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
pushd $script_dir

sudo pacman -S --needed --noconfirm $(cat packages/pacman)
paru -S --needed --noconfirm $(cat packages/aur)
