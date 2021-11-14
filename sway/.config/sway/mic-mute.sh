#!/usr/bin/bash

# Check what state the mic is currently
muted=$(pactl get-source-mute @DEFAULT_SOURCE@)

# toggle this state and send according notification
if [[ $muted == "Mute: yes" ]] 
then
  pactl set-source-mute @DEFAULT_SOURCE@ 0 | notify-send -u critical -t 1000 "Mic activated"
else 
  pactl set-source-mute @DEFAULT_SOURCE@ 1 | notify-send -t 1000 "Mic deactived"
fi

