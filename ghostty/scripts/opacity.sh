#!/bin/bash

CONFIG_FILE="$HOME/.config/ghostty/config"
STEP=0.1

# Find the current opacity (default to 1.0 if not set)
CURRENT=$(grep "^background-opacity" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
if [ -z "$CURRENT" ]; then
  CURRENT=1.0
fi

# Check the arguments
if [[ "$1" == "inc" || "$1" == "dec" ]]; then
  # Use awk to handle the math if we are stepping up or down
  NEW=$(LC_ALL=C awk -v cur="$CURRENT" -v step="$STEP" -v op="$1" 'BEGIN {
        new_val = (op == "inc") ? (cur + step) : (cur - step)
        if (new_val > 1.0) new_val = 1.0
        if (new_val < 0.1) new_val = 0.1
        printf "%.2f", new_val
    }')
else
  # Default jump if neither inc nor dec are specified
  NEW="0.6"
fi

# Replace or append the setting
if grep -q "^background-opacity" "$CONFIG_FILE"; then
  sed -i '' "s/^background-opacity.*/background-opacity = $NEW/" "$CONFIG_FILE"
else
  echo "background-opacity = $NEW" >>"$CONFIG_FILE"
fi

sleep 0.05

# Trigger Ghostty's config reload via your custom chord (ctrl+s, then r)
osascript \
  -e 'tell application "System Events"' \
  -e '  tell process "Ghostty"' \
  -e '    set frontmost to true' \
  -e '    keystroke "s" using {control down}' \
  -e '    delay 0.05' \
  -e '    keystroke "r"' \
  -e '  end tell' \
  -e 'end tell'
