##################
# General
##################
export EDITOR=/sbin/vim
export BROWSER=/sbin/firefox
export TERMINAL=/sbin/alacritty
export PAGER=/sbin/less
export SHELL=/usr/bin/zsh


##################
# Go Env
##################
export GOROOT="/home/technat/go"
export GOBIN=$GOROOT"bin"

##################
# NNN
##################
export NNN_OPTS="ecdx"
export NNN_FCOLORS='000000000000000000000000'
export NNN_FIFO="/tmp/nnn.fifo" # comment out and add "a" option to NNN_OPTS if you want multiple preview windows for multiple nnn instances.
export NNN_PLUG="i:imgview;p:preview-tui;t:preview-tabbed"
export NNN_PREVIEWDIR="~/.config/nnn/previews"
export ICONLOOKUP=1
export GUI=1
export NNN_TRASH=1
export NNN_OPENER="/home/technat/.config/nnn/plugins/nuke"
