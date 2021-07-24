# Arch on my TMBPR 

Install Arch on my Mac Book Pro 13" Mid 2015
WARNING! This guide is not up to date with my current knowledge. And nowdays I don't use a mac so this guide definitely needs an update.

## Components in this installation
* systemd-boot
* LVM on LUKS
* Swapfile
* NetworkManager
* Gnome

## Disclaimer
I documented how i installed Arch Linux on my Mac book to have a reference i can use if something goes wrong and i need to know how i configured it. It's also a preparation for the installation as i can test this guide on a virtual machine or another mac and if i know that these commands work, i can configure my system in one run.

It's mostly for myself, but maybe someone finds it helpful too. Let me know if it was a help for you.

## Boot Medium
On a Linux Machine with a usb stick plugged in and internet access these commands will turn your usb stick into a bootable arch linux medium:
```
#get arch iso from swiss mirror
wget https://mirror.puzzle.ch/archlinux/iso/2020.09.01/archlinux-2020.09.01-x86_64.iso
#change to download directory
cd Download
#use dd to copy iso to usb stick, replace sdx with the correct identifier for the usb stick, make sure the name for the iso is correct as well
dd if=archlinux-2020.09.01-x86_64.iso of=/dev/sdx bs=4M
```

## Preparations on live installation
Before installing Arch on the actual ssd, there are some checks and configs to do on the live installation.

### Check UEFI boot mode
Output of the directory below should not be empty, then we are in uefi mode:
`ls /sys/firmware/efi/efivars //should exists for uefi boot`

### Change terminal font
Terminal Font is very small, a bigger font would be sun12x22 or ter-122n:
`setfont ter-g20b`

### Configure internet access to download packages
Plug in a cable and check with ping that it worked:
`ping -c 5 technat.ch`

If you want to use wifi you can configure it for this live session:
`wifi-menu`

however this does not work in every case. For this cases wpa_supplicant:
`wpa_supplicant -B -i interface -c <(wpa_passphrase MYSSID passphrase)`

see [here](https://wiki.archlinux.org/index.php/Wpa_supplicant) for more details about wpa_supplicant.

To see if an ip address is assigned
`ip addr show`

Start dhcp renew
`dhcpcd`

### Active NTP
set ntp to have an up to date time during installation
`timedatectl set-ntp true`

### Pacman mirror list
generate new pacman mirror list with swiss http mirros (packages are signed with gpg keys, no needs for slower https):
`reflector —protocol http -c Switzerland —sort rate —save /etc/pacman.d/mirrorlist`

### Update package list for live session
`pacman -Syyy`

## Partitioning
Now start with the actual installation. We need to partiton the internal ssd.
Find the correct drive with `lsblk`

I'am gone use lvm on luks and the boot mode is uefi, so i'm just doing the efi partiton and one big partition i'm splitting with lvm later:

| Drive Letter    | Part Nr  | Size               | Type                   |
|----------------------|-------------|------------------|-----------------------|
| /dev/sdx1        | 1             | 50G               | 1 EFI System    |
| /dev/sdx2        | 2             | 100G             | 30 Linux LVM  |

### Enter partition dialog
using fdisk, enter partiton dialog and create new fresh gpt signature, aka wipe all partitions
```
fdisk /dev/sdx
g
```

### Create EFI partition
```
n
enter
enter
+500M
t
1
```

### Create lvm partition
```
n
enter
enter
enter
t
enter
30
```

### save and exit fdisk
```
p
w
```

## Encrypt lvm partition with luks
I'am encrypting the hole lvm partiton with luks before creating logical volumes

### create encryption
`cryptsetup luksFormat -v -s 512 -h sha512 /dev/sdx2`

Type YES to continue and enter a strong password twice

### Open encrypted disk for further use
`cryptsetup luksOpen /dev/sdx2 lvm`

## LVM pv, vg and lv

### Physical Volume
Create a physical volume, eq our /dev/sdx2. dataalignment is set to 1m because macbook has an ssd
`pvcreate --dataalignment 1m /dev/mapper/lvm`

### Volume Group
`vgcreate vgcrypt /dev/mapper/lvm`

### Logical Volumes
```
lvcreate -L 50GB vgcrypt -n vgcrypt-root
lvcreate -L 100GB vgcrypt -n vgcrypt-home
#full size only if lvm snapshots are not used
lvcreate -l 100%FREE vgcrypt -n vgcrypt-home
modprobe dm_mod
vgscan
vgchange -ay
```

## Formatting the partitons
Fat32 for EFI Partition, EXT4 for Logical Volumes
```
mkfs.fat -F32 /dev/sdx1
mkfs.ext4 /dev/vgcrypt/vgcrypt-root
mkfs.ext4 /dev/vgcrypt/vgcrypt-home
```

## Mount partitions
Now mount the partitions in live system to install packages on it and save configurations
```
mount /dev/vgcrypt/vgcrypt-root /mnt
mkdir /mnt/home
mkdir /mnt/boot
mkdir /mnt/etc
mount /dev/vgcrypt/vgcrypt-home /mnt/home
mount /dev/sdx1 /mnt/boot
```

## Generate fstab file

### Generate
Now is a good time to add the mounted partitions to the fstab file
Doing that with genfstab ensures everything is correct
`genfstab -U -p /mnt >> /mnt/etc/fstab`

### Change mount options
Because we have an ssd we add some specific options to the mount options of the lvm partitons
```
vim /mnt/etc/fstab
#mount options for lvm partitions:
rw,relatime,data=ordered,discard
```

## Install base system with pacstrap
Install the base system on the mounted disk in multiple steps

### Base
`pacstrap -i /mnt base base-devel`

### Kernel, headers and firmware
`pacstrap -i /mnt linux linux-headers linux-firmware`

or for lts
`pacstrap -i /mnt linux-lts linux-lts-headers linux-firmware`

## arch-chroot
Change root dir to /mnt to continue with configuration
`arch-chroot /mnt`

## Install system packages

### set mirror list
Because we are now on our installation and no longer on the live medium, we have to configure the mirror list again:
`reflector -c switzerland —protocol http —sort rate —save /etc/pacman.d/mirrorlist`

and of course update the package list again to have a current list:
`pacman -Syyy`

### Editor
`pacman -S vim`

### Networking
`pacman -S networkmanager`

### LVM
`pacman -S lvm2`

### Graphics
`pacman -S mesa xorg-server xf86-video-intel`

### CPU instruction set
`pacman -S intel-ucode`

### Other
`pacman -S dialog sudo terminus-font`

## Regional Settings

### Language
Generate language pack for later use, save env var with default
```
vim /etc/locale.gen
#uncomment en_US.UTF-8
#generate language
locale-gen
#set default to english
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

### Fonts
we set a bigger font for the live installation, to make this the default size for the installation, we downloaded the terminus-font package and can now set the font as an enviornment var.
```
vim /etc/vconsole.conf
#add your prefered font, a list of all fonts can be found in /usr/share/kbd/consolefonts/
FONT=ter-g20b
```

Note: if you get warnings when building the initramfs that say your consolefont is not found, this could be because the installation does not contain the same collection of fonts as the live system. If it's a font beginning with `ter-` install the terminus-font package to get these fonts for your installation.

### Timezone
Create hardlink to the correct timezone file, then set hwclock to time format UTC
```
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
hwclock --systohc --utc
```

## Keyboard Layout

I'm using the english (US) Layout so theroretically I don't need to change anything on the keyboard layout. However because I'm from Switzerland and SMS are usually in swiss german I need to type öüä quite a lot. So I switched from standard english (US) to english (Intl., with AltGr dead keys). Here are the commands for that:

```

localectl list-keymaps

localectl set-keymap --no-convert us

```

## initramfs
Because we use lvm, luks and we have a mac we need to add some hooks to the initramfs config:
```
vim /etc/mkinitcpio.conf
#find line where it says HOOKS=(), make sure these hooks are set in the correct order:
HOOKS=(base udev autodetect modconf block consolefont keyboard keymap encrypt lvm2 filesystems fsck)
#regenrate the image
mkinitcpio -p linux
#for lts
mkinitcpio -p linux-lts
```

We add the consolefont hook here. This package the custom configured font to the initramds and loads it very early in the boot process.

## Users
set a password for root user and configure a new admin user for yourself.

### Root
Set a root password:
`passwd`

### Personal User
Create your own admin user:
```
#create user
useradd -m -g users -G wheel username
#set password
passwd username
#allow all users of wheel group to run sudo commands when entering their password
EDITOR=vim visudo
#in the file uncomment this line:
%wheel ALL=(ALL) ALL
```

## Configure networking

### Check drivers
The very first step with networking is to see if the correct drivers are loaded. The linux kernel does quite a lot for you and if you don't have a very special network card or wifi card, the correct driver should already be picked by the kernel and loaded.

To verify that run `lspci -k` and see what drivers are loaded for your NIC.

Another way to check if they are loaded correctly is by running `ip link` and see if the network device is listed and has the status up. To change the status `ip set device {devicename} up`

Attention! The state is not what you are looking for. if an interface is up or not can be seen by the UP or DOWN inside the <> brackets:
```
technat@tmbpr:~$ ip link show dev wlp3s0
8: wlp3s0: <BROADCAST,MULTICAST,**UP**,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DORMANT group default qlen 1000
    link/ether ac:bc:32:9b:0f:7b brd ff:ff:ff:ff:ff:ff
```


### NetworkManager
We could do all the networking manually, but the simplest option is to install a Manager that does everything for you. NetworkManager was allready installed in the section where system packages are installed, we just have to enable the service at boot:

`systemctl enable NetworkManager`

### Hostname
To set the hostname of the machine, type this command and replace myhostname with a custom name:
` hostnamectl set-hostname myhostname`

## Bootloader systemd-boot
Macs should work well with systemd-boot.

GRUB is also an option, but we already use systemd for other stuff so why not do an uniform setup.

### Create bootloader entry file for arch
```
#create bootloader directory
mkdir -p /boot/loader/entries
#get partuuid of logical volume root and save in entry file
blkid /dev/vgcrypt/vgcrypt-root >> /boot/loader/entries/arch.conf
#edit bootloader entry for arch
vim /boot/loader/entries/arch.conf
################## Content #######################
title   Arch Linux
linux   /vmlinuz-linux
initrd /intel-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID={UUID}:luks:allow-discards root=/dev/mapper/vgcrypt vgcrypt--root quiet rw
##################################################3
```

or for lts you can either add an additional config or do just one:
```
#create bootloader directory
mkdir -p /boot/loader/entries
#get partuuid of logical volume root and save in entry file
blkid /dev/vgcrypt/vgcrypt-root >> /boot/loader/entries/arch-lts.conf
#edit bootloader entry for arch
vim /boot/loader/entries/arch.conf
################## Content #######################
title   Arch Linux (LTS Kernel)
linux   /vmlinuz-linux-lts
initrd /intel-ucode.img
initrd  /initramfs-linux-lts.img
options cryptdevice=UUID={UUID}:luks:allow-discards root=/dev/mapper/vgcrypt vgcrypt--root quiet rw
##################################################3
```

### Create bootloader config
```
vim /boot/loader/loader.conf
################### Content #####################
default arch
#default arch-lts
timeout 4
console-mode max
editor 0
#################################################
```

### Install bootloader on efi partition
`bootctl --path=/boot install`

## Configure swapfile

### Create swapfile
If you have 16g or more Memory a swapfile is propably not used.
```
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
```

### Add swapfile to fstab
```
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /etc/fstab
```

## Reboot
Now exit the installation, unmount disks and reboot the mac to see if he can boot the fresh installed arch.
```
exit
#unmount disks, some errors are okay
umount -a
reboot
```z

Login as root after reboot

### WiFi Connection
Now that we are on the fresh installation we have to setup network again. With a cable everything should work allready as network manager does everything, with wifi we have to configure it. This time with the nmcli which is used to configure NetworkManager:

```
nmcli device wifi list
nmcli device wifi connect SSID password password
```

or if you prefer a  console like gui, type `nmtui` and add a new network connection.

see [nmcli examples](https://wiki.archlinux.org/index.php/NetworkManager#nmcli_examples) for more help with it. Once a gui is installed, this brings it's own tool that communicates with NetworkManager but is of course graphical. Although NetworkManager would have an X11 graphical tool.

## Install Desktop Environment

### GDM
Gnome Display Manager, used to login and start gnome session

`pacman -S gdm`

and enable it
`systemctl enable gdm`
w

### Gnome and a theme
`pacman -S gnome adwaita-icon-theme arc-gtk-theme`

Enter a couple times to accept the defaults asked


### Reboot
`reboot`


## Post Installation

### Install AUR Helper
```
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Power management
We already set a kernel boot parameter to fix a wake up problem with extreme cpu temperatures, but there is more:

#### Wake up Problem
XHCI can wake up the macbook in sleep mode and when lid is closed which results in hot macbooks in backpacks and less battery life. To check if XHCI can do that run:

`cat /proc/acpi/wakeup`

if on the line where xhci is it says enbaled,  we have to disable it by creating a udev rule:
```
sudo vim /etc/udev/rules.d/90-xhc_sleep.rules
################## content ######################################
# disable wake from S3 on XHC1
SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"
################################################################
reboot
cat /proc/acpi/wakeup
```

#### mbpfan-git
Something that could be usefull is mbpfan-git. A package from the AUR Repository to control fan speeds. Install and enable it like that:
```
yay mbpfan-git
sudo systemctl enable --now mbpfan
```
Note: this needs the modules "coretemp" and "appelsmc" to be loaded. To do this add them to the /etc/modules file

### WiFi
My Mac Book had no problem with the wifi card as the driver was picked up right away. The output of `lspci -k` shows the following for the wifi card:

```
03:00.0 Network controller: Broadcom Inc. and subsidiaries BCM43602 802.11ac Wireless LAN SoC (rev 01)
        Subsystem: Apple Inc. Device 0133
        Kernel driver in use: brcmfmac
        Kernel modules: brcmfmac
```

However there are macs with other wifi cards that need some additional drivers. One could be the broadcom-wl driver from the AUR Repository. To know which drivers is used, to a quick internet search with the name of your wifi card, macbook and arch. My WiFi Card's name is  "BCM43602"

### Bluetooth
From the official arch linux wiki, the following steps are required to setup bluetooth very generic on linux

>   1. Install the bluez package, providing the Bluetooth protocol stack.
    2. Install the bluez-utils package, providing the bluetoothctl utility. Alternatively install bluez-utils-compatAUR to additionally have the deprecated BlueZ tools.
    3. The generic Bluetooth driver is the btusb kernel module. Check whether that module is loaded. If it's not, then load the module.
    4. Start/enable bluetooth.service.

Simple right?

The bluez and bluez-utils packages are installed with yay or pacman:

`sudo pacman -S bluez bluez-utils`

To check where btusb is loaded and used run a `lsmod | grep btusb`

You should see that bluetooth is using it:
```
bluetooth             720896  43 btrtl,btintel,btbcm,bnep,btusb,rfcomm
```

The last step is to enable and start the bluetooth systemd service. After that the toogle for bluetooth in gnome should work and in gnome settings devices to pair should appear:

`sudo systemctl enable --now bluetooth.service`


If can be (like on my mac) that rfkill blocked the bluetooth module. Check that with `rfkill list`:

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

From now bluetooth should work like a charm. Kinda, my mac book still has trouble with the MX Master 1/2S from Logitech and with bluetooth headsets to playback music continously

### Sound
I had no issues with sound once gnome was installed, so i wait with that as long as it's not needed.

### Touchpad
Touchpad works fine with gnome, even natural scrolling works.

A more specific mac like trackpad config can be used for xf86-input-libinput (packages is installed when installing gnome)

see the specific model recommendations for macs on the [official wiki page] (https://wiki.archlinux.org/index.php/Mac) for more details

## Sources
* https://mchladek.me/post/arch-mbp/
* https://gist.github.com/OdinsPlasmaRifle/e16700b83624ff44316f87d9cdbb5c94
* https://medium.com/@laurynas.karvelis_95228/install-arch-linux-on-macbook-pro-11-2-retina-install-guide-for-year-2017-2034ceed4cb2
* https://0xadada.pub/2016/03/05/install-encrypted-arch-linux-on-apple-macbook-pro/

