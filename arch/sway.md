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

## Firefox
Firefox can run nativally on Wayland with the following tweak:

```
cat <<EOF >/etc/environment
MOZ_ENABLE_FIREFOX=1
EOF
```

## 