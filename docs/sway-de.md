# Sway DE
My Setup of a Wayland Compositor with all the tools needed to make more or less a full fleged Desktop Environment suited to my needs.

## Workflow
My workflow for setting things up is to follow this guide with cloning the repo first. All the config files for different programms live in this repo so it's best practise to clone it first into my home folder so that is can be reached at `~/WALL-E`:

```
git clone https://git.technat.ch/technat/WALL-E.git
git clone ssh://git@git.technat.ch:9999/technat/WALL-E.git # if ssh is setup
```

In order to use the config files from this repo I further use `stow` to symlink the files to the correct location, so it's a good idea to install that before starting:
```
sudo pacman -S stow
```

## Sway
The first thing we need from a basic arch installation is sway (the wayland compositor) and ly which is my display manager of choice:

```
sudo pacman -S sway 
yay -aS ly-git
```

Once their installed we can enable the display manager to start at boot and symlink the sway config to it's place:
```
systemctl enable ly
cd ~/WALL-E
stow sway
```

To activate the changes I reboot the system now.

After you reboot you should see a terminal like display manager with a login prompt. Login to the shell as for sway not everything is yet redady to use.


### Sway configs

#### Clamshell mode
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

### Philosohpy about Wayland and XWayland
Wayland aims to be the new replacement for X. But X is over 20 years old and it's very deep rooted in linux. So a switch is not easy. When using wayland these days you will almost all times run in situations where applicatons don't support wayland or not by default. Luckily there is [XWayland](https://wiki.archlinux.org/title/Wayland#XWayland). But those applications that support wayland should run on wayland right?

So how to manage that. My first approach was to set environment variables in `/etc/environment` that forced applications to use wayland. But the you get an application that uses the same gui libary but doesn't support it. What do you do? You change the environment variable to force all application from this libary to use XWayland. Not pretty and not reliable as chaning an environment variable can help one application and refuse another one to start.

So what I like to do is take the .desktop file of an application that doesn't run with sway **default settings** and modify it so that is launches with the correct environment variables set. To prevent if from beeing overwritten by upgrade all custom .desktop files should be located in `~/.local/share/applications`. This helps keeping track of which applications needed modifications to run and which ones are working jst fine by default.

## System Utilities
The sway config assumes that there are some programms for different functionalities already installed. This includes a tool for screenshots, clipboard-management or application launching. Of course you could change those tools in the sway config to the tools of your choice but most of the time you need to make some adjustments so that the tools work together. In this section we are going through all of these system utilities, the one I have choosen and how to make it work with sway.

### Installation
Let's start by installing all the system utilities:
```
sudo pacman -S alacritty sway-launcher-desktop rofi python-pip python-setuptools waybar nnn nextcloud-client gnome-keyring xorg-wayland firefox keepassxc qt5-wayland qt5ct tmux vim zsh
sudo pacman -S pulseaudio pavucontrol pamixer pulseaudio-bluetooth playerctl 
yay -aS nerd-fonts-complete shotman clipman wob brightnessctl dropbox dropbox-cli vmware-workstation
```

nnn dependencies:
```
yay -aS bat viu ffmpegthumbnailer file pdftoppm fontpreview glow sxiv tabbed xdotool jq trash-cli vidir
```

vim plugin dependencies:
```
sudo pacman -S npm nodejs yarn go
```

This could take a while...

### Alacritty
The most important programm to configure is a terminal mutliplexer. My choice is `alacritty` as it's the default for swaywm and it has graphics acceleration which makes it super fast.
It has a config file located at `~/.config/alacritty/alacritty.yml` and some themes in the same folder. We just symlink the entire config folder:

```
cd ~/WALL-E
stow alacritty
```

Note: The alacritty config uses firacode as the font for the terminal. If you have installed the `nerd-fonts-complete` package from above this will work, otherwise you may need to change the font or install firacode manually.

Source: https://github.com/alacritty/alacritty

#### zsh
I'm using zsh with the [oh-my-zsh](https://ohmyz.sh/) framework. Let's install that too now.

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm ~/.zshrc
cd ~/WALL-E
stow zsh
```

#### vim
My favourite editor. Hopefully already installed, but my `.vimrc` is missing:

```
cd ~/WALL-E
stow vim
```

For plugins to be used we need [vim-plug](https://github.com/junegunn/vim-plug). It will install itself when starting vim for the first time as well as installing all the plugins.

Note: Some of the plugins have external dependencies that have to be installed first. But this was already done at the beginning of this chapter.

#### tmux
With a tiling window manager like swaywm it's not really necessary to use tmux but let's set it up:

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~/WALL-E
stow tmux
tmux # prefix + I to install plugins
``` 

Note: You need to adjust the terminal colors of your terminal emulator to match solarized dark theme. Otherwise the colors aren't okay.

### shotman
Shotman is a utility to do screenshots. It's linked to the keybinding $mod+Shift+S. It has no special configuration except the keybinding which is set in sway's config. 

Just note that it is written in python and needs `pip` and `setuptools` installed.

Source: https://gitlab.com/WhyNotHugo/shotman/-/tree/main

### clipman
The clipboard manager I'm using. It is one that works native on wayland. Bound to Ctrl+Shift+H to browse the history. To show the history it uses an application launcher. Unfortunatelly I didn't got it working with `sway-launcher-desktop` so `rofi` is needed as well.

Source: https://github.com/yory8/clipman

### Waybar
Sway ships with a default bar which can be customized a bit. A much more customizable bar is `waybar`. 

Waybar has a seperate config in `~/.config/waybar/`. The `config` file defines all the modules which are display and the `style.css` stylies the modules.

To link the config:
```
cd ~/WALL-E
stow waybar
```

Source: https://github.com/Alexays/Waybar

Note: Waybar also uses FiraCode as it's font so make sure you have this installed. For icons it needs `ttf-font-awesome` or the patched nerdfont firacode.

### Audio
If we want to play some music we need some software for sounds. 
For [general purpose audio](https://wiki.archlinux.org/index.php/Sound_system) `pulseaudio` in combination with `alsa` is used.

The `pulseaudio` package is the most obvious one there. For bluetooth devices the `pulseuadio-bluetooth` is needed. 
The `pavucontrol` is a GUI to confiure `pulseaudio`. The `pamixer` and `playerctl` utilies are used to control volume and music with keybindings which are defined in sway.

#### Volume
To change the volume the `pamixer` utility is used. It is a cli communicating with `pulseaudio` It has the ability to get the current volume and therefore display the progress using `wob`.

#### Music
To control music, play and pause we use `playerctl`. Also a CLI which uses keybindings in sway's config to control the music streams.

#### Bluetooth Audio
To load the necessary bluetooth modules on startup we need to add them to the pulseaudio config:

```
cat <<EOF >>/etc/pulse/system.pa
### Load bluetooth modules
load-module module-bluetooth-policy
load-module module-bluetooth-discover
EOF
```

### Brightness
To change the brightness of the screen we use a tool called `brightnessctl`.  

The keybindings are set in sway's config so that it should already work.
To display a nice status bar how much brightness we have we use `wob` to display a progress bar.

Source: https://github.com/Hummer12007/brightnessctl
Source: https://github.com/francma/wob

### File Manager
I use nnn as my file manager as it can handle image previews and much more while beeing fast. 

But just installing nnn is not enough, it needs to be configured. This is done using some environment variables. If you have stowed my zsh config the vars are already set.

Otherwise export them somewhere in rc file:

```
cat ~/WALL-E/zsh/.zshenv | grep "nnn Vars" -A 20
```

nnn itself is not very spectacular. What makes it really interesting are the plugins you can use. So for my config I use the plugins. You can find them [here](https://github.com/jarun/nnn/tree/master/plugins) and in this directory you will also find a neat one-liner to download them:

```
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
```

Now you can find the plugins in `~/.config/nnn/plugins`. Start using them by exporting the `NNN_PLUG` variable. 

While setting up my own nnn config I realized that most of the nnn plugins are just helpers to integrate with other programms out there. That's why you end up installing some more tools to work perfectly with nnn. They are listed in a separated install command at the top of this chapter.

#### Plugins
* `p:preview-tui` - File preview in terminal or tmux pane, very basic 
* `t:preview-tabbed` - File preview with correct programm - usefull for image sorting

Source: https://github.com/jarun/nnn

### Application launcher
`sway-launcher-desktop` is my application launcher. It has a keybinding $mod+Space to launch it.
It is also responsible to autostart applications using some config in sway's config file.

Application which want autostart need to have a .desktop file in `~/.config/autostart/` 

Source: https://github.com/Biont/sway-launcher-desktop

### Dropbox
The `dropbox-cli autostart y` command places a .desktop file in `~.config/autostart` which will execute dropbox when sway instance is started. This is because the sway-launcher-desktop application is told to execute .desktop files in this directory when sway starts. See the end of the sway config for more details

Docs and further informations: https://wiki.archlinux.org/title/Dropbox

### Nextcloud sync client
The nextcloud-client want's to save nextcloud credentials in gnome keyring. So this package has to be installed first. Nextcloud-Client will create a default keyring and ask for a master password when setting up the nextcloud-client. 
Then on every login you will be prompted for this master password

### Firefox
Firefox can run nativally on Wayland when forcing it do do so:

```
cp /usr/share/applications/firefox.desktop ~/.local/share/applications/firefox.desktop
sed -i 's/Exec=/Exec=env MOZ_ENABLE_WAYLAND=1 /g' ~/.local/share/applications/firefox.desktop
```

For more informations and known problems see [here](https://wiki.archlinux.org/title/Firefox).

### vmware-workstation
Enter the license:
```
sudo /usr/lib/vmware/bin/vmware-vmx-debug --new-sn XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
```

And enable the networking service:
```
sudo systemctl enable vmware-networks --now
```

Note: To enter the license you need to be root. But launching vmware with wayland means that you cannot run vmware as root. So how do you enter the license? Because even when vmware launches on your desktop, the licence can not be entered as there are root privileges requied. So entering it on the command line fixed that problem for me.

Note2: If you get an error saying that `vmmon` is not loaded. This can probably be because the package `linux-headers` is not installed on the system

#### Networking in vmware
If you have a vmnet that is host-only, you can only set a fixed ip subnet in the `vmware-netcfg` (where vmware will take the first address of the subnet for the host!). But there's no way to set dns or any other ip than the first one. So here's how you can create a NetworkManager connection to make this host-only adapter configurable by NetworkManager:

```
[connection]
id=smartlearn
uuid=39372746-0e7d-4391-87bd-118e64196848
type=ethernet
interface-name=vmnet1
permissions=

[ethernet]
mac-address=00:50:56:C0:00:01
mac-address-blacklist=

[ipv4]
address1=192.168.210.254/24,192.168.210.1
dns=192.168.220.12;
dns-search=smartlearn.lan;smartlearn.dmz;
method=manual
route1=192.168.220.0/24,192.168.210.1

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]
```

#### Workaround for vmware-netcfg
When running vmware-netcfg as root, the following error appears:
```
Authorization required, but no authorization protocol specified

(vmware-netcfg:1617): Gtk-WARNING : 12:08:44.302: cannot open display: :0
```

This can be temporarly fixed by installing `xorg-xhost` and running the following command:

```
xhost si:localuser:root
```

More informations on running vmware: https://wiki.archlinux.org/title/VMware.

### KeePassXC
KeePassXC is using qt5. When launching with default settings there is an error:
```
qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""
[1]    6043 segmentation fault (core dumped)  keepassxc
```

This is easily fixed by installing the wayland plugin for qt5: `qt5-wayland`.

Then it launches. But we can do even more. The [arch linux wiki]() points out that some QT applications, including KeePassXC have missing functionality on Sway. To solve this we also install `qt5ct` and set an environment variable in the .desktop file of keepass:

```
cp /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
sed -i 's/Exec=/Exec=env QT_QPA_PLATFORMTHEME=qt5ct /g' ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
```

## Known Issues and fixes
### GTK+ aplpications take 20 seconds to start
See https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start

## Further reading
* [https://wiki.archlinux.org/title/Wayland#GUI_libraries](https://wiki.archlinux.org/title/Wayland#GUI_libraries)
* [https://wiki.archlinux.org/title/List_of_applications/Documents](https://wiki.archlinux.org/title/List_of_applications/Documents) 


