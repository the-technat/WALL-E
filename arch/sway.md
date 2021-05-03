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
echo MOX_ENABLE_FIREFOX=1 | sudo tee -a /etc/environment
```

## shotman
Screenshot tool

```
sudo pamcan -S python-pip python-setuptools
yay shotman
```

Config is placed in sway's config. 
Software Repo: https://gitlab.com/WhyNotHugo/shotman/-/tree/main

## QT Applications
From https://github.com/swaywm/sway/wiki#disabling-client-side-qt-decorations:

```
echo QT_QPA_PLATFORM=wayland |sudo tee -a /etc/environment
echo QT_WAYLAND_DISABLE_WINDOWDECORATION="1" | sudo tee -a /etc/environment
```

## Waybar
The waybar config is already stowed when stowing sway config, and waybar is also executed, but there are some fonts missing:

```
yay Iosevka
yay ttf-font-awesome
```

## vmware-workstation
Install it:

```
yay vmware-workstation
```

Some good documentation about it: https://wiki.archlinux.org/title/VMware#Launching_the_application.

Not actually sure what of that I will implement but surely some of it.

TODO: set correct environment variables so that vmware launches

## KeePassXC
Install it:

```
yay keepassxc
```

TODO: set correct environment variables so that keepassxc launches