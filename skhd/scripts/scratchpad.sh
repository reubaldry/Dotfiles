#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Find the exact window ID of the Scratchpad
WIN_ID=$(yabai -m query --windows | jq -r '.[] | select(.app == "Ghostty" and .title == "Scratchpad") | .id')

if [ -z "$WIN_ID" ] || [ "$WIN_ID" == "null" ]; then
  # LAUNCH IT: It doesn't exist yet, so we use your dedicated config
  open -n -a Ghostty --args --config-file=$HOME/.config/ghostty/custom_configs/scratchpad
else
  # TOGGLE IT: It exists, so we check if you are currently looking at it
  IS_FOCUSED=$(yabai -m query --windows --window "$WIN_ID" | jq -r '."has-focus"')

  if [ "$IS_FOCUSED" == "true" ]; then
    # It's focused right now -> Hide it by minimizing
    yabai -m window "$WIN_ID" --space last
    yabai -m window "$WIN_ID" --grid 8:8:2:2:4:4
    yabai -m window --focus first
  else
    # It's hidden or on another workspace -> Bring it here and focus
    # yabai -m window --deminimize "$WIN_ID"
    CURRENT_SPACE=$(yabai -m query --spaces --space | jq -r '.index')
    yabai -m window "$WIN_ID" --space "$CURRENT_SPACE"
    yabai -m window "$WIN_ID" --grid 8:8:2:2:4:4
    yabai -m window --focus "$WIN_ID"
  fi
fi
