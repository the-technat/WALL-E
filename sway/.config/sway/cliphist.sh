#!/sbin/env sh
## =============================================================================
##
## Part of Sway configuration (https://code.immerda.ch/technat/wall-e)
##
## Wrapper script for cliphist (Clipboard Manager)
## doesn't save copied text to history when caller was KeePassXC
##
## =============================================================================
app_id=$( swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .app_id'  )
cliphist store

