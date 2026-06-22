#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

YAB_RUNNING=$(pgrep -i yabai)

if [[ "$YAB_RUNNING" = "" ]]; then
  yabai --start-service
else
  yabai --stop-service
fi
