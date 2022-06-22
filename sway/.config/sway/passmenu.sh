#!/usr/bin/env bash
## =============================================================================
##
## Part of Sway configuration (https://github.com/the-technat/WALL-E)
##
## Used to browse password-store using bemenu launcher
##
## =============================================================================

shopt -s nullglob globstar

# Solarized Dark
export BEMENU_OPTS='\
    -H 21
    --tb "#002b36" \
    --tf "#93a1a1" \
    --fb "#002b36" \
    --ff "#93a1a1" \
    --nb "#002b36" \
    --nf "#93a1a1" \
    --hb "#002b36" \
    --hf "#859900" \
    --fbb "#002b36" \
    --fbf "#93a1a1" \
    --sb "#002b36" \
    --sf "#93a1a1" \
    --scb "#002b36" \
    --scf "#93a1a1" \
    --fn "font pango:rubik 11"' 

# Solarized Light
# export BEMENU_OPTS='\
#    -H 21 \
#    --tb "#eee8d5" \
#    --tf "#586e75" \
#    --fb "#eee8d5" \
#    --ff "#586e75" \
#    --nb "#eee8d5" \
#    --nf "#586e75" \
#    --hb "#eee8d5" \
#    --hf "#268bd2" \
#    --fbb "#eee8d5" \
#    --fbf "#586e75" \
#    --sb "#eee8d5" \
#    --sf "#586e75" \
#    --scb "#eee8d5" \
#    --scf "#586e75" \
#    --fn "font pango:rubik 11"'


typeit=0
if [[ $1 == "--type" ]]; then
	typeit=1
	shift
fi

if [[ -n $WAYLAND_DISPLAY ]]; then
	dmenu=bemenu 
  	xdotool="ydotool type --file -"
elif [[ -n $DISPLAY ]]; then
	dmenu=dmenu
	xdotool="xdotool type --clearmodifiers --file -"
else
	echo "Error: No Wayland or X11 display detected" >&2
	exit 1
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

password=$(printf '%s\n' "${password_files[@]}" | "$dmenu" "$@")

[[ -n $password ]] || exit

if [[ $typeit -eq 0 ]]; then
	pass show -c "$password" 2>/dev/null
else
	pass show "$password" | { IFS= read -r pass; printf %s "$pass"; } | $xdotool
fi
