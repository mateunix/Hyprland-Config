#!/bin/bash

# Function to get current brightness level (0-120000)
get_brightness() {
  brightnessctl g
}

# Function to set brightness (value between 0 and 120000)
set_brightness() {
  brightnessctl s "$1"
}

# Function to send a notification using notify-send
send_notification() {
  local icon="$1"
  local percent="$2"
  notify-send -u normal -i "notification-display-brightness" "Backlight" "$icon $percent%"
}

# Maximum brightness value (120000)
MAX_BRIGHTNESS=120000

# Get current brightness and calculate percentage
brightness=$(get_brightness)
percent=$((brightness * 100 / MAX_BRIGHTNESS))

# Define icons for different brightness levels (use Unicode characters here)
icons=("" "" "" "" "" "" "" "" "")

# Map percentage to icon (9 levels)
level=$((percent / 11)) # Roughly dividing 0-100 into 9 levels
icon=${icons[$level]}

# If argument is "increase", increase brightness by 5%
if [ "$1" == "increase" ]; then
  new_brightness=$((brightness + (MAX_BRIGHTNESS * 5 / 100)))                           # Increase brightness by 5%
  new_brightness=$((new_brightness > MAX_BRIGHTNESS ? MAX_BRIGHTNESS : new_brightness)) # Cap at MAX_BRIGHTNESS
  set_brightness "$new_brightness"                                                      # Update brightness
  new_percent=$((new_brightness * 100 / MAX_BRIGHTNESS))                                # Calculate new percentage
  send_notification "${icons[$((new_percent / 11))]}" "$new_percent"                    # Send notification

# If argument is "decrease", decrease brightness by 5%
elif [ "$1" == "decrease" ]; then
  new_brightness=$((brightness - (MAX_BRIGHTNESS * 5 / 100)))        # Decrease brightness by 5%
  new_brightness=$((new_brightness < 1 ? 1 : new_brightness))        # Prevent going below 1 and turning the screen black
  set_brightness "$new_brightness"                                   # Update brightness
  new_percent=$((new_brightness * 100 / MAX_BRIGHTNESS))             # Calculate new percentage
  send_notification "${icons[$((new_percent / 11))]}" "$new_percent" # Send notification

# If no argument, just display the current brightness as a notification
else
  send_notification "$icon" "$percent" # Display current brightness notification
fi
