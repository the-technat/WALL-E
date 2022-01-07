# Start a screen recording of the current screen, use default audio input
bindsym Ctrl+$mod+Alt+Enter exec sway-record -d $(swaymsg -t get_tree | jq 'recurse(.nodes[]) | \
  select(.nodes[].focused == true).output') -m $(pactl get-default-source) | notify-send -u critcal -t 1000 "Screen recording of current screen"
