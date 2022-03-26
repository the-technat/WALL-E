# Arch on my WALL-E

Install Arch Linux on my notebook.

## Components in this installation

Arch Linux is flexible and there are many guides out there that show you how to install it. During research I found it unpleasant having to read the entire article before knowing what software the article shows to configure for different components. Therefore here's the list of what Software I use:

* Partitioning: btrfs *(sub-volumes) on LUKS partition -> all data encrypted (except boot partition)
* Bootloader: systemd-boot
* SWAP: zramd

## Disclaimer

I documented how I installed Arch Linux on my notebook to have a reference I can use if something goes wrong and I need to know how I configured it. It's also a preparation for the installation as I can test this guide on a virtual machine or another computer and if I know that these commands work, I can configure my system in one run. But note that I'm also just one of many computer scientists and not all have the same opinion concering how things are get done.

So this guide is mostly for myself, but maybe someone finds it helpful too. Let me know if it was a help for you.

## Boot Medium

On a Linux Machine with a usb stick plugged in and internet access these commands will turn your usb stick `/dev/sdx` into a bootable arch linux medium:

```bash
wget https://mirror.puzzle.ch/archlinux/iso/2022.03.01/archlinux-2022.03.01-x86_64.iso 
cd Download
dd if=archlinux-2022.03.01-x86_64.iso of=/dev/sdx bs=4M
```

Or if you want to learn something new check out [this mutliboot software](https://www.ventoy.net/en/index.html).

## Preparations on live installation

Before installing Arch on the actual disk, there are some checks and configs to do on the live installation.

1. Output of the directory below should not be empty, then we are sure we booted in uefi mode:

```bash
ls /sys/firmware/efi/efivars 
```

1. The default terminal font is quite small and on most laptops this is not perfect, we can change it:

```bash
ls /usr/share/kbd/consolefonts # list of all available fonts on live system 
setfont ter-g20b
```

1. Plug in a cable and check with ping that you got an internet connection:

```bash
ping -c 5 technat.ch
```

1. If you want to use wifi you can configure it for this live session. Replace `ssid1` with the name of your WiFi and put the password inside the single quotes:

```bash
iwctl --passphrase '' station wlan0 connect ssid1
```

1. set NTP to have an up to date time during installation:

```bash
timedatectl set-ntp true
```

1. generate new pacman mirror list with swiss http mirros (packages are signed with gpg keys, no needs for slower https):

```bash
pacman -Syy
reflector —protocol http -c Switzerland —sort rate —save /etc/pacman.d/mirrorlist
```

Now you should be good to go with the installation. Note that you'll download quite a lot of packages during the installation, so the faster your internet connection is, the less ☕ you'll need :)

## Partitioning

Okay we are in our live system. But how can we now install arch? Let's start by partitioning the disk. For this you need the correct drive. You can find it with `lsblk`:

```bash
NAME                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                             8:0    0 476.9G  0 disk
```

In my case it's `/dev/sda`. For the rest of this installation all commands with the disk use `/dev/sda`. If your drive is another one change that accordingly.
But how does the partitioning layout look like?

Like that:

| Drive Letter    | Part Nr  | Size                  | Type          |
|-----------------|----------|-----------------------|---------------|
| /dev/sda1       | 1        | 300M                  | 1 EFI System  |
| /dev/sda2       | 2        | Reminder of the space | 20 Linux fileysystem  |

As we have a UEFI system we just need one small boot partition for the bootloader. This is the unencrypted part of the installation. The second partition will be encrypted using LUKS and then formated using btrfs.

Using fdisk, enter partiton dialog and create new fresh GPT signature, aka wipe all partitions and data!

```bash
fdisk /dev/sda
g
```

Still in the dialog type those commands to create the first partition:

```bash
n
enter
enter
+300M
t
1
```

And for the second partiton we need those commands:

```bash
n
enter
enter
enter
```

Now we write the changes to the disk and exit the fdisk dialog:

```bash
p
w
```

### Encrypt btrfs partition with LUKS

Before we format the partitions we encrypt the second partition with LUKS:

```bash
cryptsetup luksFormat -v /dev/sda2
```

Type YES to continue and enter a strong password twice.

Now it's encrypted. But we need to install the system on it so let's open it again:

```bash
cryptsetup luksOpen /dev/sda2 luks
```

Note: when opening the device you have to give it a name. I called mine `luks` but you can rename it to whatever you want. We will use this name later so remember it :)

## Formatting

Now that partitioning is done we need to format our volumes. The `boot` partition should be FAT32, the second partition will be btrfs.

Note that we are not formatting the second partiton directly as this partition is encrypted, but instead the device that luks is providing to us.

```bash
mkfs.vfat /dev/sda1
mkfs.btrfs /dev/mapper/luks
```

### btrfs sub-volumes

Now that we have the btrfs file-system on `/dev/mapper/luks` we can create our sub-volumes for different mount-points. I like to create multiple ones to see where I use the most space and organzie them. Here's an overviev of the sub-volumes with their mount-options we are going to use later:

| subvol Name  | Mount point            | Mount options                                                         | 
|--------------|------------------------|-----------------------------------------------------------------------|
| @            | /                      | noatime,nodiratime,discard=async,compress=zstd,space_cache=v2,ssd,subvol=@          |
| @var         | /var                   | noatime,nodiratime,discard=async,compress=zstd,space_cache=v2,ssd,subvol=@var       | 
| @tmp         | /tmp                   | noatime,nodiratime,discard=async,compress=zstd,space_cache=v2,ssd,subvol=@tmp       | 
| @home        | /home                  | noatime,nodiratime,discard=async,compress=zstd,space_cache=v2,ssd,subvol=@home      | 

So we create the sub-volumes, for this the luks device has to be mounted:

```bash
mount /dev/mapper/luks /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@var
btrfs sub create /mnt/@tmp
btrfs sub create /mnt/@home
umount /mnt
```

Now that the sub-volumes are created we can mount them in the correct order:

```bash
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@ /dev/mapper/luks /mnt
mkdir -p /mnt/{boot,home,var,tmp}
mount -o noatime,nodiratime,compress=zstd,discard=async,space_cache=v2,ssd,subvol=@var /dev/mapper/luks /mnt/var
mount -o noatime,nodiratime,compress=zstd,discard=async,space_cache=v2,ssd,subvol=@tmp /dev/mapper/luks /mnt/tmp
mount -o noatime,nodiratime,compress=zstd,discard=async,space_cache=v2,ssd,subvol=@home /dev/mapper/luks /mnt/home
```

Finally mount the EFI partition:

```bash
mount /dev/sda1 /mnt/boot
```

## Generate fstab file

Before bootstraping let's create a `fstab` file:

```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
```

## Bootstrap system

From now we are ready to get a system on our disk. In arch there is a tool called `pacstrap` that does the heavy lifting for us.
To start be install the `base` package alongside the `linux` package (which is the actual kernel). The `linux-firmware` package contains drivers for many hardware and is in my case used to get the correct wifi drivers. The last `base-devel` package contains multiple tools for development and compiling. It's usually required for packages from the AUR (they are compiled locally).

```bash
pacstrap -i /mnt base base-devel linux linux-firmware linux-headers
# pacstrap -i /mnt base base-devel linux-lts linux-firmware linux-lts-headers
```

Note the second commented line. You can either install the normal kernel, or the LTS-kernel or both. The LTS or Long-Time-Support kernel is known for it's focus on stability and it's security updates over many years. It can be a good idea to install both so you always have a fallback if your main kernel breaks something on an update. Note that if something is wrong with your installation (if you mixed up your init-ramfs or you forgot to remove a mount from fstab for example) the LTS entry won't help you as the root disk is still the same.

Does anyone notice that a Nerd (which uses Kernel 5.16.15 at the time of this writting) has written this description about LTS 🤣?

### arch-chroot

After we've installed the base system we can change our root to /mnt so that we can do further configurations to the os-disk:

```bash
arch-chroot /mnt
```

## Install more packages

On top of the base system we are going to install even more packages:

```bash
pacman -Syy
pacman -S vim intel-ucode git terminus-font networkmanager zsh dosfstools mtools 
```

For networking you have multiple options which are very good [documented](https://wiki.archlinux.org/index.php/Network_configuration). I stick to `NetworkManager` but you can also choose something else.

I recommend to enable the service for NetworkManager and the fstrim which should startup at first boot right now:

```bash
sudo systemctl enable NetworkManager
sudo systemctl enable fstrim.timer
```

## Regional Settings

Once the packages are there we go on and configure our regional stuff. We start by generating our locales in `/etc/locale.gen`. Uncomment your appropriate language and then generate the language pack:

```bash
locale-gen
```

The configured language needs to be set in the `/etc/locale.conf` file as follows:

```bash
LANG=en_US.UTF-8
```

We installed the terminus-font package so let's make use of it by setting our font in the `/etc/vconsole.conf` file.
If you want to try a font use `setfont` to change the font, this will not persist over reboots. A list of all available fonts in the system can be seen in `/usr/share/kdb/consolefonts/`

```bash
FONT=ter-g20b
```

Note: if you get warnings when building the initramfs that say your consolefont is not found, this could be because the installation does not contain the same collection of fonts as the live system. If it's a font beginning with `ter-` install the terminus-font package to get these fonts for your installation.

To set the timezone we just use a hardlink to `/etc/localetime` like so:

```bash
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
hwclock --systohc
```

I'm using the english (US) Layout so theroretically I don't need to change anything on the keyboard layout. However because I'm from Switzerland and you sometimes need to write something in swiss german I need to type öüä quite a lot. So I switched from standard english (US) to english (Intl., with AltGr dead keys). Anyway here's how you could change the default keyboard layout:

```bash
localectl list-keymaps # to list all keyboard layouts 
```

And then write your's to `/etc/vconsole.conf` as follows:

```bash
KEYMAP=us-acentos
```

## root password

To login after the reboot we need to set a root password:

```bash
passwd
```

## Hostname

Set the hostname of the machine (chose your own):

```bash
echo WALL-E > /etc/hostname
```

And adjust the /etc/hosts file accordingly:

```bash
cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1   localhost
127.0.1.1 WALL-E.silver.lan WALL-E
EOF
```


## initramfs

As the documentation for Arch linux says the initramfs should automatically be generated when installing the base system with pacstrap. But the default initramfs doesn't contain support for btrfs and the encryption, so we need to add this.

I edit `/etc/mkinitcpio.conf` and change the HOOKS and MODULEs lines to look like this:

If you want to know more about the order and the hooks for the initramfs I highly recommend reading [this page](https://wiki.archlinux.org/index.php/Mkinitcpio) from the arch linux wiki.

```bash
MODULES=*(btrfs)
HOOKS=(base systemd keyboard sd-vconsole autodetect modconf block sd-encrypt fsck filesystems)
```

Note that the `btrfs` hook is not used, the wiki says that this is not needed when we don't use btrfs over multiple drives.

If we change something in this file, we need to regenerate the initramfs:

```bash
mkinitcpio -p linux
mkinitcpio -p linux-lts # if you have an LTS kernel
```

## bootloader

At the beginning of the tutorial I said that this installation is a UEFI installation and that I'm going to use systemd-boot as my bootloader. There are mutliple options depending on your preference and your setup. See [here](https://wiki.archlinux.org/index.php/Arch_boot_process) for more information on other options.

First we initialize the bootloader:

```bash
systemd-machine-id-setup
bootctl --path=/boot install
```

Now we need to create a bootloader entry. For this we need to know the UUID for the second partition. We get it with the following command:

```bash
uuid=$(blkid --match-tag UUID -o value /dev/sda2)
```

Note that we don't get the UUID of the luks device nor the root sub-volume but instead of the disk partition. This is fine as we specify the luks device and sub-volume to use in the bootloader entry. 

So let's add an entry to our bootloader:

```bash
cat <<EOF >/boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd /intel-ucode.img
initrd  /initramfs-linux.img
# initrd /initramfs-linux-lts.img
options rd.luks.name=${uuid}=luks root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=discard 
EOF
```

And we also change the bootloader config to use the above entry as default:

```bash
cat <<EOF >/boot/loader/loader.conf
default arch
#default arch-lts
console-mode max
timeout 0
editor 0
EOF
```

The `editor 0` directive disables the option to add kernel parameters during boot. The `timeout 0` specified to wait 0 seconds before continuing to boot. So you won't see the bootloader with the different options if you don't press space during boot.

## Keyfile

On my machine I have a problem which causes the keyboard to not work during the early boot process (BIOS problem) even with the keyboard hook in initramfs.
So I used a workaround which uses a keyfile stored in the initramfs to unlock the LUKS partition. This is not very secure as the initramfs is stored on the `/dev/sda1` partition which is not encrypted and anyone with access to the disk could extract the keyfile and then decrypt your data. A better option would be to store the keyfile on a thumb drive and insert this everytime you boot. But I'm not at a point where I think this is necessary for me. If you want to do it you can read everything about it [here](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption).

So that's what I did to fix my problem:

```bash
dd bs=512 count=4 if=/dev/random of=/keyfile iflag=fullblock
chmod 400 /etc/mykeyfile
cryptsetup luksAddKey /dev/sda2 /keyfile
```

then in the `/etc/mkinitcpio.conf` file I added the following to the FILES array:

```bash
FILES=(/keyfile)
```

Regenerated the initramfs:

```bash
mkinitcpio -p linux
```

and then added the following to the options line in the boot entry:

```bash
options rd.luks.key=${uuid}=/keyfile 
```

## Success?

So this is it for the installation. Now you can `exit` the arch-chroot environment and `reboot` the system to proofe that you successfully installed a working arch linux!

If the installation fails to boot I recommend you boot back into the live system, decrypt the LUKS partition, mount the volumes again and take another look at your boot entry.
From my experience typos in the bootloader config are the most common cause of problems :=)

## Recommended first steps

Before using your system I recommend you do some basic steps, some of them are optional, some of them are quite important.

## Personal user

There are reasons why we shouldn't work with `root` day by day:

```bash
useradd -m -g users -G wheel,storage,power -s /usr/bin/zsh technat
passwd technat
```

## Networking

When following my Arch Install Guide there isn't any network manager or dhcp client running. But we installed `NetworkManager` during the installation.

So to get network connectivity it's as simple as running the following commands:

```bash
nmcli device wifi list
nmcli device wifi connect SSID password password
```

More information about `nmcli` can be found [here](https://wiki.archlinux.org/index.php/NetworkManager#nmcli_examples). Note that there is also a more user-firendly `nmtui` that can also be used to interact with `NetworkManager`.

Well not always Networking (and especially WiFi) works as expected. So let's take a step back and go through all the things that could go wrong.

### Check drivers

The most important thing is to see wether the system has detected our network interface and can use it by loading the correct driver for it. Normally the linux kernel does a good job by picking the correct default driver for your network interface (that's why you have `linux-firmware` package). Let's check if he did:

```bash
lspci -k | grep -i net -A 3
```

You should see at least one network interface listed. My output is as follows:

```bash
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

### DNS

NetworkManager has multiple ways to resolve Names. One is to delegate DNS to the `systemd-resolved` service. For this the following has to be set:

```bash
sudo cat <<EOF >/etc/NetworkManager/conf.d/dns.conf
[main]
dns=systemd-resolved
EOF
sudo systemctl enable --now systemd-resolved
```

From now on DNS is completly managed by `systemd-resolved`.
Note: `/etc/resolv.conf` is now also managed by `systemd-resolved`. See [this page](https://wiki.archlinux.org/title/NetworkManager#/etc/resolv.conf) for how NetworkManager uses or doesn't use the `/etc/resolv.conf` file.

### Captive portals

See [NetworkManager](https://wiki.archlinux.org/title/NetworkManager#Configuration) for a list of solutions to make networkamanger open a browser window when you connect to a network that has a captive portal.

### WPA2_Enterprise Networks

Universities and schools often use wpa2-enterprise networks where you have to authenticate yourself with credentials instead of a pre-shared-key.
NetworkManager can connect to such WiFi's but seems like you have to do it via a manual added connection.

So create a file in `/etc/NetworkManager/system-connections/[CONNECTION_NAME].nmconnection` and place the following content in it:

```bash
[connection]
id=[CONNECTION_NAME]
uuid=[UUID]
type=wifi
interface-name=[WIFI-INTERFACE NAME]
permissions=

[wifi]
mac-address-blacklist=
mode=infrastructure
ssid=[SSID]

[wifi-security]
auth-alg=open
key-mgmt=wpa-eap

[802-1x]
eap=peap;
identity=[USERNAME]
password=[PASSWORD]
phase2-auth=mschapv2

[ipv4]
dns-search=
method=auto

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]
```

Replace the [] place holder with the correct values. An UUID can be generated with `uuidgen`.

[Wiki Page](https://github.com/wylermr/NetworkManager-WPA2-Enterprise-Setup)

## Bluetooth

From the official arch linux wiki, the following steps are required to setup bluetooth very generic on linux:

>   1. Install the bluez package, providing the Bluetooth protocol stack.
    2. Install the bluez-utils package, providing the bluetoothctl utility.
    3. The generic Bluetooth driver is the btusb kernel module. Check whether that module is loaded. If it's not, then load the module.
    4. Start/enable bluetooth.service.

Simple right?

The bluez and bluez-utils packages can be installed with pacman:

```bash
pacman -S bluez bluez-utils
```

To check where btusb is loaded and used run a `lsmod | grep btusb`

You should see that bluetooth is using it:

```bash
bluetooth             720896  43 btrtl,btintel,btbcm,bnep,btusb,rfcomm
```

The last step is to enable and start the bluetooth systemd service:

```bash
systemctl enable --now bluetooth.service
```

It's possible that rfkill blocks the bluetooth module which can cause special behaviour. Check that with `rfkill list`:

My output was as following:

```bash
0: hci0: Bluetooth
        Soft blocked: yes
        Hard blocked: no
1: phy0: Wireless LAN
        Soft blocked: no
        Hard blocked: no
```

There is a "yes" by soft blocked bluetooth. I fixed this by running `rkfill unblock bluetooth`.

From now bluetooth should work. You can use `bluetoothctl` to pair bluetooth devices or use any GUI Application that uses it unter the hood.
To power on the bluetooth controller on startup see [here](https://wiki.archlinux.org/title/Bluetooth#Auto_power-on_after_boot).

### Bluetooth Headsets

For bluetooth headsets see this [wiki page](https://wiki.archlinux.org/title/Bluetooth_headset#Disable_auto_switching_headset_to_HSP/HFP).

## Sudo

To issue commands as root without chaning the user to root we need `sudo`. On arch it's not installed by default. So let's install it:

```bash
pacman -S sudo
```

On arch the `sudo` group is called `wheel`. So we can configure all users of the wheel group to allow running sudo. We edit the sudoers file with `EDITOR=vim visudo` and uncomment the following:

```bash
%wheel ALL=(ALL) ALL #--> will prompt for password when using sudo
%wheel ALL=(ALL) NOPASSWD: ALL #--> won't prompt for password when using sudo
```

## zramd

We don't use swap, but we want to use [zram](https://en.wikipedia.org/wiki/Zram).

To do this it's as simple as:

```bash
sudo pacman -S zramd
sudo systemctl enable --now zramd.service
```

## AUR Helper

To install packages from the Arch User Repository you'll either need to do it manually or install a helper which get's your new package manager. It will be able to compile packages from the AUR as well as us pacman in the back to install regular packages. I use yay for that but there are other options as well:

```bash
sudo pacman -S git go
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Note: Once yay is installed it can update itself in the future ;).

## Timeshift

We use btrfs, so let's enable automatic snapshots by installing timeshift:

```bash
sudo pacman -S timeshift
yay -aS timeshift-autosnap
```

Open timeshift and finish the configuration to your likings.

## Cups

For printing we need the [cups](https://wiki.archlinux.org/title/CUPS) system. Install and enable it:

```bash
sudo pacman -S cups
sudo systemctl enable --now cups
```

## What's next?

Okay now you have a decent system which you can work with. But there is still no graphical interface. Depending on your use case for the machine this might be fine. For me I need some sort of a graphical environment to work. If you are interested on how I have done that see  my [Sway-DE Guide](./sway-de.md). There I noted how to do these things and much more.

pacman -S dialog network-manager-applet xdg-user-dirs xdg-utils  

## Further Reading

* [https://paedubucher.ch/articles/2020-09-26-arch-linux-setup-with-disk-encryption.html](https://paedubucher.ch/articles/2020-09-26-arch-linux-setup-with-disk-encryption.html)
