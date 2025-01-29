#!/bin/bash

# Start swayidle
if [ -f "/usr/bin/swayidle" ]; then
  echo "swayidle is installed."
  swayidle -w timeout 300 '~/.config/hypr/scripts/swaylock.sh' timeout 360 'systemctl suspend -f' before-sleep '~/.config/hypr/scripts/swaylock.sh'
else
  echo "swayidle not installed."
fi
