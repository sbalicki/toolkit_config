#!/bin/bash

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  NORMAL=""
fi

############ Install favourite programs ############
printf "${GREEN}Installing favourite programs\n${NORMAL}"
sudo apt install chromium chromium-l10n vlc gparted eclipse aptitude dconf-editor \
    mate-desktop-environment-extra mate-desktop-environment-extras -y
