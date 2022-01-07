# Sway DE

My Setup of a Wayland Compositor with all the tools needed to be productive, while only having what is really necessary.

## How to setup

My workflow for setting things up is to follow this guide with cloning the repo first. All the config files for different programms live in this repo so it's best to clone it first into my home folder so that is can be reached at `~/WALL-E`:

```bash
git clone https://git.technat.ch/technat/WALL-E.git
```

In order to use the config files from this repo I further use `stow` to symlink the files to the correct location, so it's a good idea to install that before starting:

```bash
sudo pacman -S stow
```

Then we can get started with a cup of ☕.

## Sway

The first thing we need from a basic arch installation is sway (the wayland compositor) and ly which is my [display manager](https://wiki.archlinux.org/title/Display_manager) of choice. Alacritty as the default terminal emulator should also be installed so that we can do further configs:

```bash
sudo pacman -S sway alacritty 
yay -aS ly-git
```

Once their installed we can enable the display manager to start at boot and symlink the sway config to it's place:

```bash
sudo systemctl enable ly
sudo systemctl disable getty@tty2.service
cd ~/WALL-E
stow sway
```

To activate the changes I reboot the system now. After you reboot you should see a terminal like display manager with a login prompt.
You can now login to sway. Use Super+Enter to launch alacritty.

### Swaylock / Swayidle

To lock your screen on keypress or after some idle time there are official packages for sway.
Config approach taken from: [here](https://code.krister.ee/lock-screen-in-sway/)

You need the following packages:

```bash
yay -aS swaylock-effects
sudo pacman -S swayidle
```

The rest is in sway's config dir already configured.

### Clamshell mode

I'm using my laptop in a dockingstation when working at home. This is called `clamshell mode` as your laptop's screen is closed but the computer is running. The [sway docs](https://github.com/swaywm/sway/wiki#clamshell-mode) tell you how you can configure sway to use this.

Depending on your laptop the output name for your internal screen might be different. You can find the corret name when running `swaymsg -t get_outputs` and looking for your internal display. You need to change the output Name in `~/.config/sway/clamshell.sh`

### Philosophy about Wayland and XWayland

Wayland aims to be the new replacement for X. But X is over 20 years old and it's very deep rooted in linux. So a switch is not easy. When using wayland these days you will almost all times run in situations where applicatons don't support wayland or not by default. Luckily there is [XWayland](https://wiki.archlinux.org/title/Wayland#XWayland). But those applications that support wayland should run on wayland right?

So how to manage that. My first approach was to set environment variables in `/etc/environment` that forced applications to use wayland. But then you get an application that doesn't support wayland but uses the same GUI libary than a programm that you forced to use wayland using environment variables for the GUI libary. How do you solve this? You change the same environment variable to force all applications from this libary to use XWayland. Not pretty and not reliable as chaning an environment variables can help one application and refuse another one to start.

So what I like to do is take the .desktop file of an application that doesn't run with sway **default settings** and modify it so that it launches with the correct environment variables set. To prevent if from beeing overwritten by upgrades. All custom .desktop files should be located in `~/.local/share/applications`. This helps keeping track of which applications needed modifications to run and which ones are working just fine by default. So when we go and configure system utilities now, remember this approach.

Oh and before I forget it, `xwayland` must be installed:

```bash
sudo pacman -S xorg-xwayland
```

## System Utilities

As the intro says, sway is not anything. We need some good tooling to be productive. We already put our sway config inf place. Sway's config is optimized to work with a specific set of tools, so we need to install and configure them now.

### Fonts

We start with fonts, because some applications depend on those fonts. There is project called [Nerd Fonts](https://www.nerdfonts.com/) that collects fonts all over the place and patches them for developer use.

In their words:
> Nerd Fonts patches developer targeted fonts with a high number of glyphs (icons). Specifically to add a high number of extra glyphs from popular ‘iconic fonts’ such as Font Awesome, Devicons, Octicons, and others.

We can install all of them on our system like so:

```bash
yay -aS nerd-fonts-complete
```

But this takes a while, the repo with all the fonts is huge.

### Alacritty

We already installed alacritty (and use it now for setup), but we haven't configured it. Alacritty has a config file in yaml where we can set some exiting things that make us more productive (yes, also fonts ;)).

So let's install the config file:

```bash
cd ~/WALL-E
stow alacritty
```

As you may guess, the font used by alacritty is one of the Nerd Fonts, so now you definitely need them ;)

### Waybar

Sway ships with a default status bar which can be customized a bit. A much more customizable bar is `waybar`.

Waybar has a seperate config in `~/.config/waybar/`. The `config` file defines all the modules which are displayed and the `style.css` stylies the modules. I like an informative status bar and have therefore configured waybar to use solarized dark theme and a style I like.

We install and link the config as follows:

```bash
sudo pacman -S waybar
cd ~/WALL-E
stow waybar
```

[Waybar Repo](https://github.com/Alexays/Waybar)

Note: Waybar also uses Nerd Fonts ;)

### Application launcher

When using a wayland compositor you must launch your apps somehow. For this you need an application launcher.
`sway-launcher-desktop` is my application launcher of choice. It has a keybinding $mod+Space to launch it.
It is also responsible to autostart applications using some config in sway's config file.

Applications which want autostart need to have a .desktop file in `~/.config/autostart/`

We can install it like so:

```bash
sudo pacman -S sway-launcher-desktop
```

[sway-launcher-desktop Repo](https://github.com/Biont/sway-launcher-desktop)

### Editors

When it comes to my favourite editor it depends on the use case. For most things I use vim with some customization. But there are use cases where VS Code (OSS) is better. Mostly when writting Code. I haven't found a good solution for IDE / Debugging Plugins in vim.

#### vim

vim should be installed already, but the config file is missing and some dependencies for plugins:

```bash
sudo pacman -S go nodejs yarn npm
cd ~/WALL-E
stow vim
```

For plugins to be used we need [vim-plug](https://github.com/junegunn/vim-plug). It will install itself when starting vim for the first time as well as installing all the plugins.

#### Code (OSS)

For coding it's sometimes easier to use an editor like vs code instead of vim.

You install it like so:

```bash
sudo pacman -S code
cd ~/WALL-E
stow code
```

Those are the extensions I like to install:

- Go (golang)
- Docker (ms-azuretools)
- Git Graph (mhutchie)
- GitLens (eamodio)
- Terraform (hashicorp)
- Vim (vscodevim)
- YAML (Redhat)
- MarkdownLint (DavidAnson)

Keybindings not default:

- Add Cursor Below -> Ctrl+Alt+Down
- Add Cursor Above -> Ctrl+Alt+Up
- Copy Line Up -> Shift+Alt+Up
- Copy Line Down -> Shift+Alt+Down

### clipman

Sway by default only has a shared clipboard inside a container. That's not really useful. One of the most popular clipboard managers for wayland is [clipman](https://github.com/yory8/clipman).
I have bound it to the shortcut Ctrl+Shift+H for history browsing and use `rofi` to show the history.

Install it:

```bash
sudo pacman -S rofi
yay -aS clipman
```

### grim & swappy

Screenshots under Wayland can be done with different tools. I use `grim` in combination with `swappy` to edit them on the fly. To make handling easier `grimshot` as a wrapper to grim is used.

Let's installt them:

```bash
sudo pacman -S grim swappy
yay -aS grimshot
```

To launch it we use keybindings in sway's config.

However `swappy` uses a config:

```bash
cd ~/WALL-E
stow swappy
```

### Brightness

To change the brightness of the screen we use a tool called [brightnessctl](https://github.com/Hummer12007/brightnessctl).
The keybindings are set in sway's config.

Install it:

```bash
yay -aS brightnessctl
```

#### Wob

To display a nice status bar how much brightness we have we use [wob](https://github.com/francma/wob) to display a progress bar.
Wob has some configs in sway's config. If you want to use it for other progress bar things, there is a variable `$WOBSOCK` where you can put percentages in.

Install it:

```bash
yay -aS wob
```

### Audio

If we want to play some music we need some software for sounds.
For [general purpose audio](https://wiki.archlinux.org/index.php/Sound_system) the audio server `pulseaudio` on top of the kernel component `alsa` is used.

So we need to install `pulseaudio` alone with some additional software:

```bash
sudo pacman -S pulseaudio pavucontrol pulseaudio-bluetooth pulseaudio-alsa 
```

- the `pulseaudio` package contains the audio server daemon itself
- `pulseaudio-alsa` makes sure that ALSA uses pulseaudio instead of doing anything directly with applications.
- `pavucontrol` is a nice GUI to configure pulseaudio
- `pulseaudio-bluetooth` is used for bluetooth support  

#### Bluetooth Audio

[Bluetooth Headset using Pulseaudio](https://wiki.archlinux.org/title/Bluetooth_headset#Headset_via_Bluez5/PulseAudio)
To load the necessary bluetooth modules in pulseaudio on startup we need to add them to the pulseaudio config:

```bash
cat <<EOF >>/etc/pulse/system.pa
### Load bluetooth modules
load-module module-bluetooth-policy
load-module module-bluetooth-discover
load-module module-switch-on-connect
EOF
systemctl --user restart pulseaudio
```

The module `load-module module-switch-on-connect` changes pulseaudios output device as soon as a bluetooth headset is connected. For this to happen automatically you need to `trust` the bluetooth device.

#### Volume

To change the volume you can either use the `pavucontrol` utility or `volumectl`.

Install it:

```bash
yay -aS volumectl
```

Note: volumectl will display a progress bar using mako and always sets the volume for the default sink.

#### Microphone

To mute the microphonse we use `pactl` directly and the keybinding Ctrl+Win+Alt+Space.

A little script `mic-mute.sh` checks wether the default source is currently muted or not and toggles that state. It sends a notification indicating the new state.

#### Media Player Controls

To control music, play and pause we use `playerctl`. The keybindings for that are set in sway' config.

But we need to install it:

```bash
sudo pacman -S playerctl
```

### Dropbox

To get dropbox running we install it:

```bash
yay -aS dropbox dropbox-cli
```

The `dropbox-cli autostart y` command places a .desktop file in `~.config/autostart` which will execute dropbox when sway is started. This is because the sway-launcher-desktop application is told to execute .desktop files in this directory when sway starts. See the end of the sway config for more details.

Docs and further informations: [Arch Wiki Guide](https://wiki.archlinux.org/title/Dropbox)

### Nextcloud sync client

The nextcloud-client want's to save nextcloud credentials in gnome keyring. So this package has to be installed too. Nextcloud-Client will create a default keyring and ask for a master password when setting up the nextcloud-client.
Then on every login you will be prompted for this master password

Install it:

```bash
sudo pacman -S gnome-keyring nextcloud-client
```

### Firefox

Firefox can run nativally on Wayland when forcing it do do so:

```bash
sudo pacman -S firefox
cp /usr/share/applications/firefox.desktop ~/.local/share/applications/firefox.desktop
sed -i 's/Exec=/Exec=env MOZ_ENABLE_WAYLAND=1 /g' ~/.local/share/applications/firefox.desktop
```

For more informations and known problems see [here](https://wiki.archlinux.org/title/Firefox).

### vmware-workstation

For educational purposes I need vmware workstation.

Install it:

```bash
yay -aS vmware-workstation
```

Easiest way to enter the license:

```bash
sudo /usr/lib/vmware/bin/vmware-vmx-debug --new-sn XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
```

Enable the networking service:

```bash
sudo systemctl enable vmware-networks --now
```

Note: To enter the license you need to be root. But launching vmware with wayland means that you cannot run vmware as root. So how do you enter the license? Because even when vmware launches on your desktop, the licence can not be entered as there are root privileges requied. So entering it on the command line fixed that problem for me.

Note2: If you get an error saying that `vmmon` is not loaded. This can probably be because the package `linux-headers` is not installed on the system

#### Networking in vmware

If you have a vmnet that is host-only, you can only set a fixed ip subnet in the `vmware-netcfg` (where vmware will take the first address of the subnet for the host!). But there's no way to set dns or any other ip than the first one. So here's how you can create a NetworkManager connection to make this host-only adapter configurable by NetworkManager:

```bash
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

When running vmware-netcfg as root (to change something in the networking settings), the following error appears:

```bash
Authorization required, but no authorization protocol specified

(vmware-netcfg:1617): Gtk-WARNING : 12:08:44.302: cannot open display: :0
```

This can be temporarly fixed by installing `xorg-xhost` and running the following command:

```bash
xhost si:localuser:root
```

More informations on running vmware: [Arch Wiki Article](https://wiki.archlinux.org/title/VMware).

### KeePassXC

KeePassXC is using qt5. When launching with default settings there is an error:

```bash
qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""
[1]    6043 segmentation fault (core dumped)  keepassxc
```

This is easily fixed by installing the wayland plugin for qt5: `qt5-wayland`.

Then it launches. But we can do even more. The [arch linux wiki](https://wiki.archlinux.org/title/Wayland#GUI_libraries) points out that some QT applications, including KeePassXC have missing functionality on Sway. To solve this we also install `qt5ct` and set an environment variable in the .desktop file of keepass:

```bash
sudo pacman -S keepassxc qt5-wayland qt5ct
cp /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
sed -i 's/Exec=/Exec=env QT_QPA_PLATFORMTHEME=qt5ct /g' ~/.local/share/applications/org.keepassxc.KeePassXC.desktop
```

### p3x-onenote

An electron app for OneNote.
[Source](https://github.com/patrikx3/onenote)
Downloaded the AppImage as described and put a desktop file in `~/.local/share/applications/p3x-onenote.desktop`:

```bash
[Desktop Entry]
Version=1.0
Type=Application
Name=P3X Onenote
Icon=p3x-onenote
Exec=/home/technat/opt/P3X-OneNote-2021.10.109.AppImage
Comment=Linux Electron Onenote
Categories=Office;
Terminal=false
```

### USB Drives automount

The following articles are helpful:

- [Github Wiki](https://github.com/coldfix/udiskie/wiki/Usage)
- [Arch Wiki Article](https://wiki.archlinux.org/title/Udisks)

Install the following packages:

```bash
yay -S udisks2 udiskie
```

There are two ways of running `udiskie`:

1. Systemd-service as user
2. Exec in sway config

If you want option 1, install and enable the service:

```bash
yay -a udiskie-systemd-git
systemctl --user enable --now udiskie.service
```

Note: This version does not support a tray icon unless you edit the service file.

For option 2 add the following to your sway config:

```bash
exec udiskie -Nt &
```

If you notice that udiskie does not mount your thumb-driver you may want to check [here](https://github.com/coldfix/udiskie/wiki/Permissions) for permission errors.

### PDF Viewer

For PDFs you need a reader. There are many [options](https://wiki.archlinux.org/title/PDF,_PS_and_DjVu). I tried some of them and setteled on `xreader`:

```bash
sudo pacman -S xreader
xdg-mime default xreader.desktop application/pdf
```

### Notifications

To display notifications [mako](https://github.com/emersion/mako) is used.

Install it:

```bash
sudo pacman -S mako libnotiy
systemctl enable --now mako
cd ~/WALL-E
stow mako
```

You can use `makoctl` to control notifications or run Shift+alt+space to dismiss them all.

## Further reading

- [https://wiki.archlinux.org/title/Wayland#GUI_libraries](https://wiki.archlinux.org/title/Wayland#GUI_libraries)
- [https://wiki.archlinux.org/title/List_of_applications/Documents](https://wiki.archlinux.org/title/List_of_applications/Documents)
