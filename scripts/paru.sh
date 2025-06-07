#!/bin/bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git ~/Downloads/paru
cd ~/Downloads/paru
makepkg -si
cd ~
rm -rf ~/Downloads/paru
