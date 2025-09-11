#!/bin/bash

# Web browser
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
xdg-mime default firefox.desktop text/html

# Images
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/svg+xml

# PDFs and documents
xdg-mime default org.gnome.Evince.desktop application/pdf

# Videos
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-msvideo

# Audio
xdg-mime default mpv.desktop audio/mpeg
xdg-mime default mpv.desktop audio/flac
xdg-mime default mpv.desktop audio/ogg
xdg-mime default mpv.desktop audio/wav

# Text/code
xdg-mime default gedit.desktop text/plain
xdg-mime default gedit.desktop text/x-csrc
xdg-mime default gedit.desktop text/x-c++src
xdg-mime default gedit.desktop text/x-python
xdg-mime default gedit.desktop text/x-shellscript
xdg-mime default gedit.desktop application/json
xdg-mime default gedit.desktop application/x-yaml

# File manager
xdg-mime default Thunar.desktop inode/directory

# Archives
xdg-mime default thunar-archive-plugin.desktop application/zip
xdg-mime default thunar-archive-plugin.desktop application/x-7z-compressed
xdg-mime default thunar-archive-plugin.desktop application/x-tar
xdg-mime default thunar-archive-plugin.desktop application/x-bzip2
xdg-mime default thunar-archive-plugin.desktop application/x-xz
xdg-mime default thunar-archive-plugin.desktop application/x-rar

# Misc obvious associations
xdg-mime default org.gnome.Calendar.desktop text/calendar
