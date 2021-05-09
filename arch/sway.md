# Sway
I've put my sway setup to a separate file as those things depend on each other and it's not that easy.

## Install Sway & Ly 
Obviously this has to be done at the beginning:

```
sudo pacman -S sway alacritty sway-launcher-desktop
yay ly-git clipman
systemctl enable ly
reboot
cd WALL-E
stow sway
```

With that you link my sway config and have the basis things already working.

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

## shotman
Screenshot tool

```
sudo pamcan -S python-pip python-setuptools
yay shotman
```

Config is placed in sway's config so it's alreadt stowed. 
Software Repo: https://gitlab.com/WhyNotHugo/shotman/-/tree/main

## Waybar
The waybar config is already stowed when stowing sway config, and waybar is also executed, but there are some fonts missing:

```
yay Iosevka
yay ttf-font-awesome
```

## Philosohpy about Wayland and XWayland
Wayland aims to be the new replacement for X. But X is over 20 years old and it's very deep rooted in linux. So a switch is not easy. When using wayland these days you will almost all times run in situations where applicatons don't support wayland or not by default. Luckily there is [XWayland](https://wiki.archlinux.org/title/Wayland#XWayland). But those applications that support wayland should run on wayland right?

So how to manage that. My first approach was to set environment variables in `/etc/environment` that forced applications to use wayland. But the you get an application that uses the same gui libary but doesn't support it. What do you do? You change the environment variable to force all application from this libary to use XWayland. Not pretty and not reliable as chaning an environment variable can help one application and refuse another one to start.

So what I like to do is take the .desktop file of an application that doesn't run with sway **default settings** and modify it so that is launches with the correct environment variables set. To prevent if from beeing overwritten by upgrade all custom .desktop files should be located in `~/.local/share/applications`. This helps keeping track of which applications needed modifications to run and which ones are working jst fine by default.

This page will lay out how to modify some common applications to run on sway.

### Instaling XWayland
XWayland is enabled by default in sway, but it seems like the `sway` package doesn't install xwayland. So you have to install it:

```
sudo pacman -S xorg-xwayland
```

### Firefox
Firefox can run nativally on Wayland when forcing it do do so:

```
cp /usr/share/applications/firefox.desktop ~/.local/share/applications/firefox.desktop
sed -i 's/Exec=/Exec=env MOZ_ENABLE_WAYLAND=1 /g' ~/.local/share/applications/firefox.desktop
```

For more informations and known problems see [here](https://wiki.archlinux.org/title/Firefox).

### vmware-workstation
Install it:

```
yay vmware-workstation
```

Enter the license:
```
sudo /usr/lib/vmware/bin/vmware-vmx-debug --new-sn XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
```

Note: To enter the license you need to be root. But launching vmware with wayland means that you cannot run vmware as root. So how do you enter the license? Because even when vmware launches on your desktop, the licence can not be entered as there are root privileges requied. So entering it on the command line fixed that problem for me.

More informations on running vmware: https://wiki.archlinux.org/title/VMware.

### KeePassXC
KeePassXC is using qt5. When launching with default settings there is an error:
```
qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""
[1]    6043 segmentation fault (core dumped)  keepassxc
```

This is easily fixed by installing the wayland plugin for qt5:
```
sudo pacman -S qt5-wayland
```

Then it launches. But we can do even more. The [arch linux wiki]() points out that some QT applications, including KeePassXC have missing functionality on Sway. To solve this we also install `qt5ct` and set an environment variable in the .desktop file of keepass:

```
sudo pacman -S qt5ct
cp /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
sed -i 's/Exec=/Exec=env QT_QPA_PLATFORMTHEME=qt5ct /g' ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
```

## Further reading
* [https://wiki.archlinux.org/title/Wayland#GUI_libraries](https://wiki.archlinux.org/title/Wayland#GUI_libraries)
* [https://wiki.archlinux.org/title/List_of_applications/Documents](https://wiki.archlinux.org/title/List_of_applications/Documents) 


