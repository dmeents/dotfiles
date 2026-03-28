#!/bin/bash
# Set Warp as the default terminal for GTK applications
# hash: warp-terminal-default-v1

gsettings set org.gnome.desktop.default-applications.terminal exec 'warp-terminal'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
