#!/usr/bin/bash
# If laptop was in clamshell mode before sway reload, put it in there again
if grep -q open /proc/acpi/button/lid/LID/state; then
    swaymsg output eDP-1 enable
else
    swaymsg output eDP-1 disable
fi  
