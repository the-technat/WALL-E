# Sway
I've put my sway setup to a separate file as those things depend on each other and it's not that easy.

## Install Sway & Ly 
Obviously this has to be done at the beginning:

```
sudo pacman -S sway alacritty sway-launcher-desktop
yay ly-git
systemctl enable ly
reboot
cd WALL-E
stow sway
```

Whit that you link my sway config and have the basis things already working.

## Clamshell mode
In the config clamshell mode is already set up accordingly to [the docs](https://github.com/swaywm/sway/wiki#clamshell-mode). But you still need to run the following for it to work perfectly:


```
cat <<EOF >/sbin/clamshell
#!/usr/bin/bash
if grep -q open /proc/acpi/button/lid/LID/state; then
    swaymsg output eDP-1 enable
else
    swaymsg output eDP-1 disable
fi
EOF
chmod +x /sbin/clamshell
```

## Firefox
Firefox can run nativally on Wayland with the following tweak:

```
cat <<EOF >/etc/environment
MOZ_ENABLE_FIREFOX=1
EOF
```

## shotman
Screenshot tool

```
sudo pamcan -S python-pip python-setuptools
yay shotman
```

Config is placed in sway's config. 
Software Repo: https://gitlab.com/WhyNotHugo/shotman/-/tree/main
