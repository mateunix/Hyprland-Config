#!/bin/bash

# Color temperature settings
DAY_TEMP=6000   # Day color temperature in Kelvin
NIGHT_TEMP=3000 # Night color temperature in Kelvin

# Hyprsunset command path
HYPRSUNSET="hyprsunset"
HYPRCTL="hyprctl reload"

# Function to calculate if it's day or night based on time
is_night_time() {
  local current_hour=$(date +"%H")
  if [ "$current_hour" -ge 18 ] || [ "$current_hour" -lt 6 ]; then
    return 0 # Night time
  else
    return 1 # Day time
  fi
}

# Function to update hyprsunset based on time
update_hyprsunset() {
  if is_night_time; then
    $HYPRSUNSET -t $NIGHT_TEMP
  else
    $HYPRSUNSET -t $DAY_TEMP
  fi
  $HYPRCTL # Reload Hyprland configuration
}

# Run the script in a loop to continuously check the time
while true; do
  update_hyprsunset
  sleep 3600 # Check every hour
done
