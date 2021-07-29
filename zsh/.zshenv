export EDITOR=/sbin/vim
export BROWSER=/sbin/firefox
export TERMINAL=/sbin/alacritty
export PAGER=/sbin/less
export SHELL=/usr/bin/zsh

### nnn Vars
# export NNN_OPTS="exdP"
export NNN_OPTS="ecdx"
export BLK="04" CHR="04" DIR="04" EXE="00" REG="00" HARDLINK="00" SYMLINK="06" MISSING="00" ORPHAN="01" FIFO="0F" SOCK="0F" OTHER="02"
# export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
export NNN_FCOLORS='0000E6310000000000000000'
export NNN_FIFO="/tmp/nnn.fifo" # comment out and add "a" option to NNN_OPTS if you want multiple preview windows for multiple nnn instances.
export NNN_PLUG="i:imgview;p:preview-tui;t:preview-tabbed"
export NNN_PREVIEWDIR="~/.config/nnn/previews"
export ICONLOOKUP=1
export GUI=1
export NNN_TRASH=1
export NNN_OPENER="/home/technat/.config/nnn/plugins/nuke"
