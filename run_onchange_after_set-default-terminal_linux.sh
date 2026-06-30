#!/bin/bash
# Set Alacritty as the default terminal for GTK applications (noctalia v2)
# hash: alacritty-default-v1

gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
