#!/bin/bash
# Set kitty as the default terminal for GTK applications (noctalia v2)
# hash: kitty-default-v1

gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
