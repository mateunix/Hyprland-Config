#!/bin/bash

# Get the current volume of the speaker (output) using pactl
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')

# Get the current volume of the microphone (input) using pactl
mic_volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | sed 's/%//')

# Variable to track if we should send a notification for volume
send_volume_notification=false

# Variable to track if we should send a notification for mic
send_mic_notification=false

# Check if the script is called to increase, decrease, or toggle mute for the speaker (output)
if [ "$1" == "increase" ]; then
  # Increase volume by 5% (max 100%)
  new_volume=$((volume + 5))
  if [ "$new_volume" -gt 100 ]; then
    new_volume=100
  fi
  pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"
  volume=$new_volume
  send_volume_notification=true
elif [ "$1" == "decrease" ]; then
  # Decrease volume by 5% (min 0%)
  new_volume=$((volume - 5))
  if [ "$new_volume" -lt 0 ]; then
    new_volume=0
  fi
  pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"
  volume=$new_volume
  send_volume_notification=true
elif [ "$1" == "toggle" ]; then
  # Toggle mute for speaker (output)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  volume=$((volume)) # Keep the volume unchanged for mute toggle
  send_volume_notification=true
fi

# Check if the script is called to increase, decrease, or toggle mute for the microphone (input)
if [ "$1" == "increase_mic" ]; then
  # Increase mic volume by 5% (max 100%)
  new_mic_volume=$((mic_volume + 5))
  if [ "$new_mic_volume" -gt 100 ]; then
    new_mic_volume=100
  fi
  pactl set-source-volume @DEFAULT_SOURCE@ "${new_mic_volume}%"
  mic_volume=$new_mic_volume
  send_mic_notification=true
elif [ "$1" == "decrease_mic" ]; then
  # Decrease mic volume by 5% (min 0%)
  new_mic_volume=$((mic_volume - 5))
  if [ "$new_mic_volume" -lt 0 ]; then
    new_mic_volume=0
  fi
  pactl set-source-volume @DEFAULT_SOURCE@ "${new_mic_volume}%"
  mic_volume=$new_mic_volume
  send_mic_notification=true
elif [ "$1" == "toggle_mic" ]; then
  # Toggle mute for microphone (input)
  pactl set-source-mute @DEFAULT_SOURCE@ toggle
  mic_volume=$((mic_volume)) # Keep the mic volume unchanged for mute toggle
  send_mic_notification=true
fi

# Set the volume icon based on the speaker mute status and send notification only for volume changes
if [ "$send_volume_notification" == true ]; then
  if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "Mute: yes"; then
    icon=" " # Muted speaker (volume 0)
    volume_message="Muted"
  elif [ "$volume" -le 33 ]; then
    icon=" " # Low volume
    volume_message="$volume%"
  elif [ "$volume" -le 66 ]; then
    icon=" " # Medium volume
    volume_message="$volume%"
  else
    icon=" " # High volume
    volume_message="$volume%"
  fi
  # Create the notification for speaker (output) volume change
  notify-send "Volume" "$icon $volume_message"
fi

# Set the mic icon based on the mic mute status and send notification only for mic changes
if [ "$send_mic_notification" == true ]; then
  if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "Mute: yes"; then
    mic_icon=" " # Mic muted
    mic_message="Mic Muted"
   # Set the mic volume icon based on mic volume level
  else
    mic_icon="" # High mic volume
    mic_message="$mic_volume%"
  fi
  # Create the notification for microphone (input) volume change
  notify-send "Mic Volume" "$mic_icon $mic_message"
fi
