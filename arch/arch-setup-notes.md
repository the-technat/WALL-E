# Arch Setup Notes
Setup software on arch linux. Randomly mixed (to some extend).

## Personal user
There are reasons why we shouldn't work with `root` day by day:

```
useradd -m -g users -G wheel,storage,power -s /usr/bin/zsh technat
passwd technat
```

## Networking
When following my Arch Install Guide there isn't any network manager or dhcp client running. But we installed `NetworkManager` during the installation. 

So to get network connectivity it's as simple as running the following commands:

```
systemctl enable --now NetworkManager
nmcli device wifi list
nmcli device wifi connect SSID password password
```

More information about `nmcli` can be found [here](https://wiki.archlinux.org/index.php/NetworkManager#nmcli_examples). Note that there is a GUI like application called `nmtui` that can also be used to interact with `NetworkManager`


Well not always everything works expected. So let's take a step back and go through all the things that should be checked before running the above commands.

### Check drivers
The most important thing is to see wether the system has detected our network interface and can use it by loading the correct driver for it. Normally the linux kernel does a good job by picking the correct default driver for your network interface. Let's check if he did:

```
lspci -k | grep -i net -A 3
```

You should see at least one network interface listed. My output is as follows:

```
00:1f.6 Ethernet controller: Intel Corporation Ethernet Connection I219-LM (rev 21)
        Subsystem: Fujitsu Limited. Device 192c
        Kernel driver in use: e1000e
        Kernel modules: e1000e
02:00.0 Network controller: Intel Corporation Wireless 8260 (rev 3a)
        Subsystem: Intel Corporation Dual Band Wireless-AC 8260
        Kernel driver in use: iwlwifi
        Kernel modules: iwlwifi
```

If the NIC's are not listed you need to find the correct drivers manually. See [here](https://wiki.archlinux.org/index.php/Network_configuration/Ethernet#Device_driver) or [here](https://wiki.archlinux.org/index.php/Network_configuration/Wireless#Device_driver) for more information on how to get network drivers and load them.

## Bluetooth
From the official arch linux wiki, the following steps are required to setup bluetooth very generic on linux

>   1. Install the bluez package, providing the Bluetooth protocol stack.
    2. Install the bluez-utils package, providing the bluetoothctl utility.
    3. The generic Bluetooth driver is the btusb kernel module. Check whether that module is loaded. If it's not, then load the module.
    4. Start/enable bluetooth.service.

Simple right?

The bluez and bluez-utils packages can be installed with pacman:

```
pacman -S bluez bluez-utils
```

To check where btusb is loaded and used run a `lsmod | grep btusb`

You should see that bluetooth is using it:
```
bluetooth             720896  43 btrtl,btintel,btbcm,bnep,btusb,rfcomm
```

The last step is to enable and start the bluetooth systemd service:

```
systemctl enable --now bluetooth.service
```

It's possible that rfkill blocks the bluetooth module which can cause special behaviour. Check that with `rfkill list`:

My output was as following:
```
0: hci0: Bluetooth
        Soft blocked: yes
        Hard blocked: no
1: phy0: Wireless LAN
        Soft blocked: no
        Hard blocked: no
```

There is a "yes" by soft blocked bluetooth. I fixed this by running `rkfill unblock bluetooth`.

From now bluetooth should work. You can use `bluetoothctl` to pair bluetooth devices or use any GUI Application that uses it unter the hood. 

## Sudo
To issue commands as root without chaning the user to root we need `sudo`. On arch it's not installed by default. So let's install it:

```
pacman -S sudo
```

On arch the `sudo` group is called `wheel`. So we can configure all users of the wheel group to allow running sudo. We edit the sudoers file with `EDITOR=vim visudo` and uncomment the following:

```
%wheel ALL=(ALL) ALL --> will prompt for password when using sudo
%wheel ALL=(ALL) NOPASSWD: ALL --> won't prompt for password when using sudo
```

## Swapfile
My Arch Installation has no SWAP partition. That's because swapfiles are also good and they are way more flexible. Configure one like that:

```
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /etc/fstab
```

Tipp: Read about SWAP in the [arch linux wiki](https://wiki.archlinux.org/title/Swap).

## AUR Helper
To install packages from the Arch User Repository you'll either need to do it manually or install a helper which get's your new package manager. It will be able to compile packages from the AUR as well as us pacman in the back to install regular packages. I use yay for that but there are other options as well:

```
git clone https://aur.archlinux.org/yay.git
cd yay
sudo pacman -S go
makepkg -si
```

## oh-my-zsh
I'm using zsh with the [oh-my-zsh](https://ohmyz.sh/) framework. Install it like that:

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cd ../
rm ../.zshrc
stow oh-my-zsh
```

## vim
Setting up vim? Isn't that as easy as `sudo pacman -S vim`? Well that's half of it. But theres more to it.

For plugins to be used we need [vim-plug](https://github.com/junegunn/vim-plug):

```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

And then we want our good `.vimrc` file:

```
cd ../
stow vim
```

This creates a symlink from ../vim/.vimrc to ~/.vimrc so that my vim config is tracked using git :)

Then some plugins need dependencies:

```
sudo pacman -S npm nodejs yarn go
```

And the plugins itself need to be installed:

```
vim +PlugInstall
```

## tmux
With a tiling window manager like swaywm it's not really necessary to use tmux but let's set it up:

```
sudo pacman -S tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ../
stow tmux
tmux # prefix + I to install plugins
``` 

Note: You need to adjust the terminal colors of your terminal emulator to match solarized dark theme. Otherwise the colors aren't okay.

## Touchpad (WIP)
Read [Touchpad Synaptics](https://wiki.archlinux.org/index.php/Touchpad_Synaptics) for informations about the drivers used for the trackpad

## Audio (WIP)
See https://wiki.archlinux.org/index.php/Sound_system

## Install Desktop Environment (WIP)
Until now we haven't done anything related to Graphics, DE, WindowManager and so on. Depending on your use case for this machine and your preferences this topic is completly different. I'm experienced with gnome so I would install gnome, but I'm also interested in projects like [i3](https://wiki.archlinux.org/index.php/I3) or DE's like [budgie](https://ubuntubudgie.org/) so I don't know what to install currenlty.

So let's first try to explain what the different terms mean and how to go together

### Display Server (WIP)
When we look from the bottom the first thing we need is a display server implementing the [X Window System](https://en.wikipedia.org/wiki/X_Window_System). The most popular one is [xorg](https://wiki.archlinux.org/index.php/Xorg) as it's basically the only one that's used and it also exists for ages. The xorg-server itself needs some drivers to the graphics card. The wiki describes [the installation of drivers](https://wiki.archlinux.org/index.php/Xorg#Installation).

For my computer the graphic driers would be the following:

```
pacman -S mesa xorg-server xf86-video-intel
```

But theres more, instead of the X Window System you can also use [Wayland](https://wiki.archlinux.org/index.php/Wayland) it's a display server protocol which aims to be the successor of the X Window System. Depending on which you use the rest of the graphical stack differs a bit. Note that Wayland is newer and therefore there aren't as much options available for the other components.


### Window Manager (WIP)
On top of the xorg-server or wayland there's a window manager that manages your windows. The wiki describes it very good:

> A window manager (WM) is system software that controls the placement and appearance of windows within a windowing system in a graphical user interface (GUI). It can be part of a desktop environment (DE) or be used standalone. (https://wiki.archlinux.org/index.php/Window_manager)

In wayland you don't use a window manager but instead a compositor. They are both the display server and the window manager for wayland and therefore often called wayland compositors. Read more [here](https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)#Wayland_compositors) and [here](https://wiki.archlinux.org/index.php/Wayland#Compositors).

If I want to use gnome then it comes with it's integrated window manager [Mutter](https://en.wikipedia.org/wiki/Mutter_(software)) so we don't have to install anything in this section. But if we want to use a standalone window manager I would take a look at [i3](https://wiki.archlinux.org/index.php/I3).

### Display Manager (WIP)
A display manager is usually what is started at the end of the boot process and prompts you to login. After your login it will pull up your chosen Desktop Environment or Window Manager. You can use a console based one like `systemd-logind` or a graphical one like `gdm`. Not all display managers can pull up all desktop environments / window managers. For Gnome they provide their own display manager `gdm`.

GDM is installed as follows:

```
pacman -S gdm
systemctl enable gdm
```

### Desktop Environment (WIP)
Finally there is the desktop environment which provides your fancy GUI. There are some including a window manager and some that can go on top of a window manager.

As an example you can install gnome as follow:

```
pacman -S gnome adwaita-icon-theme arc-gtk-theme
```
