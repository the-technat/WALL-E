# Arch on my WALL-E
Install Arch Linux on my daily driver notebook.

## Components in this installation
Arch Linux is flexible and there are many guides out there that show you how to install it. During research I found it unpleasant having to read the entire article before knowing what software the article shows to configure for diferent components. Therefore here's the list of what Software I use:
* Partitioning: LVM on LUKS partition -> all data encrypted (except boot partition)
* Bootloader: systemd-boot
* SWAP: none

## Disclaimer
I documented how I installed Arch Linux on my notebook to have a reference I can use if something goes wrong and I need to know how I configured it. It's also a preparation for the installation as I can test this guide on a virtual machine or another computer and if I know that these commands work, I can configure my system in one run. But note that I'm also just one of many computer scients and not all have the same opinion concering how things are done.

So this guide is mostly for myself, but maybe someone finds it helpful too. Let me know if it was a help for you.

## Boot Medium
On a Linux Machine with a usb stick plugged in and internet access these commands will turn your usb stick `/dev/sdx` into a bootable arch linux medium:

```
wget https://theswissbay.ch/archlinux/iso/2021.02.01/archlinux-2021.05.01-x86_64.iso
cd Download
dd if=archlinux-2021.05.01-x86_64.iso of=/dev/sdx bs=4M
```

Or if you want to learn something new check out [this mutliboot software](https://www.ventoy.net/en/index.html).

## Preparations on live installation
Before installing Arch on the actual ssd, there are some checks and configs to do on the live installation.

1. Output of the directory below should not be empty, then we are sure we booted in uefi mode:
```
ls /sys/firmware/efi/efivars 
```
2. The default terminal font is quite small and on most laptops this is not perfect, we can change it:
```
ls /usr/share/kbd/consolefonts # list of all available fonts on live system 
setfont ter-g20b
```
3. Plug in a cable and check with ping that you got an internet connection:
```
ping -c 5 technat.ch
```
4. If you want to use wifi you can configure it for this live session. Replace `ssid1` with the name of your WiFi and put the password inside the single quotes: 
```
iwctl --passphrase '' station wlan0 connect ssid1
```
5. set NTP to have an up to date time during installation:
```
timedatectl set-ntp true
timedatectl set-timezone Europe/Zurich
```
6. generate new pacman mirror list with swiss http mirros (packages are signed with gpg keys, no needs for slower https):
```
pacman -Syy
reflector —protocol http -c Switzerland —sort rate —save /etc/pacman.d/mirrorlist
```

Now you should be good to go with the installation. Note that you'll download quite a lot of packages during the installation, so the faster your internet connection is, the less ☕ you'll need :)

## Partitioning
Okay we are in our live system. But how can we now install arch? Let's start by partitioning the disk. For this you need the correct drive. You can find it with `lsblk`:
```
NAME                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                             8:0    0 476.9G  0 disk
├─sda1                          8:1    0   500M  0 part
└─sda2                          8:2    0 476.5G  0 part
sdb                             8:16   0 223.6G  0 disk
├─sdb1                          8:17   0   500M  0 part  /boot
└─sdb2                          8:18   0 223.1G  0 part
  └─cryptlvm                  254:0    0 223.1G  0 crypt
    ├─vgwall--e-vgcrypt--root 254:1    0    60G  0 lvm   /
    └─vgwall--e-vgcrypt--home 254:2    0  98.7G  0 lvm   /home
```

In my case it's `/dev/sda`. For the rest of this installation all commands with the disk use `/dev/sda`. If your drive is another one change that accordingly.
But how does the partitioning layout look like?

Like that:

| Drive Letter    | Part Nr  | Size                  | Type          |
|-----------------|----------|-----------------------|---------------|
| /dev/sdx1       | 1        | 500M                  | 1 EFI System  |
| /dev/sdx2       | 2        | Reminder of the space | 30 Linux LVM  |

As we have a UEFI system we just need one small boot partition for the bootloader. This is the unecnrypted part of the installation. The second partition will be encrypted using LUKS before we use LVM to create logical volumes. 

Using fdisk, enter partiton dialog and create new fresh GPT signature, aka wipe all partitions and data!
```
fdisk /dev/sda
g
```

Still in the dialog type those commands to create the first partition:
```
n
enter
enter
enter
+500M
t
1
```

And for the second partiton we need those commands:
```
n
enter
enter
enter
t
enter
30
```

Now we write the changes to the disk and exit the fdisk dialog:
```
p
w
```

### Encrypt LVM partition with LUKS
Before we create logical volumes we encrypt the second partition with LUKS:

```
cryptsetup luksFormat -v /dev/sda2
```

Type YES to continue and enter a strong password twice.

Now it's encrypted. But we need to install the system on it so let's open it again:

```
cryptsetup luksOpen /dev/sda2 cryptlvm
```

Note: when opening the device you have to give it a name I called mine `cryptlvm` but you can rename it to whatever you want. We will use this name later so remeber it :) 

### LVM
On our encryped partition we can now setup LVM. I'm going to create multiple logical volumes:

| LV Name  | Size     | VG Name   |
|----------|----------|-----------|
| root     | 40GB     | vgcrypt   |
| var      | 20GB     | vgcrypt   |
| tmp      | 5GB      | vgcrypt   |
| vm       | 300GB    | vgcrypt   |
| home     | 100GB    | vgcrypt   |

So I start by creating a physical volume (note the `cryptlvm` name specified earlier):

```
pvcreate /dev/mapper/crpytlvm
```

On top of this PV we create a volume group:

```
vgcreate vgcrypt /dev/mapper/cryptlvm
```

And then we need to define our logical volumes:

```
lvcreate -L 40GB vgcrypt -n root
lvcreate -L 20GB vgcrypt -n var
lvcreate -L 5GB  vgcrypt -n tmp
lvcreate -L 300GB vgcrypt -n vm
lvcreate -L 100GB vgcrypt -n home
modprobe dm_mod
vgscan
vgchange -ay
```

Note: It's not necessary to create so many logical volumes. You could also just do one. But for better separation and overview about where the space is used I created multiple ones. Also I didn't fill up the entier space of my volume group. This is usefull if I have to extend a logical volume in the future as extending is easier than shrinking. But if you want you can also let one volume use the reminder of the space:

```
lvcreate -l 100%FREE vgcrypt -n home
```

## Formatting
Now that partitioning is done we need to format our volumes. The `boot` partition should be FAT32, the others can be anything you like. I use ext4.

```
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/vgcrypt/root
mkfs.ext4 /dev/vgcrypt/var
mkfs.ext4 /dev/vgcrypt/tmp
mkfs.ext4 /dev/vgcrypt/home
mkfs.ext4 /dev/vgcrypt/vm
```

## Prepare bootstraping
We're coming close to the inital bootstrap of arch. We now need to mount our volumes in the live system to install arch on them. I'm doing this from `/mnt` on, so that from the perspective of the installed system `/mnt` is `/`: 

```
mount /dev/vgcrypt/root /mnt
mkdir -p /mnt/{home,boot,vm,tmp,var,etc}
mount /dev/vgcrypt/home /mnt/home
mount /dev/vgcrypt/vm /mnt/vm
mount /dev/vgcrypt/tmp /mnt/tmp
mount /dev/vgcrypt/var /mnt/var
mount /dev/sda1 /mnt/boot
```

## Generate fstab file
Before bootstraping let's create a `fstab` file:

```
genfstab -U -p /mnt >> /mnt/etc/fstab
```

My final `/etc/fstab` file then looks like this:


```
# /dev/mapper/vgcrypt-root
UUID=083b5377-f768-445b-81eb-0154ee77bb75       /               ext4            rw,relatime     0 1

# /dev/mapper/vgcrypt-home
UUID=21c4372a-88d5-406d-b7e2-a88aea95dedd       /home           ext4            rw,relatime     0 2

# /dev/mapper/vgcrypt-vm
UUID=39635044-d2b3-42fa-b24c-ebf1602d558d       /vm             ext4            rw,relatime     0 2

# /dev/mapper/vgcrypt-tmp
UUID=91858b84-ef95-45cc-bc83-eb60b22a8646       /tmp            ext4            rw,relatime     0 2

# /dev/mapper/vgcrypt-var
UUID=de61f80f-529b-4884-99e1-f034a2542f8f       /var            ext4            rw,relatime     0 2

# /dev/sda1
UUID=73FB-6274          /boot           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro   0 2

/swapfile none swap sw 0 0
```

Note: UUIDs are different on every system.

## Bootstrap system
From now we are ready to get a system on our disk. In arch there is a tool called `pacstrap` that does the heavy lifting for us.
To start be install the `base` package alongside the `linux` package (which is the actual kernel). Then be also install `lvm2` because the system needs lvm support. The `linux-firmware` package contains drivers for many hardware and is in my case used to get the correct wifi drivers. The last `base-devel` package conains multiple tools for development and compiling. It's required for package from the AUR.

```
pacstrap -i /mnt base base-devel linux linux-firmware lvm2
# pacstrap -i /mnt base base-devdl linux-lts linux-firmware lvm2
```

Note the second commented line, you can either install the normal kernel, or the LTS-kernel or both. The LTS or Long-Time-Support kernel is known for it's focus on stability and it's security updates over many years. It can be a good idea to install both so you always have a fallback if your main kernel breaks something on an update. Note that if something is wrong with your installation (if you mixed up your init-ramfs or you forgot to remove a mount from fstab for example) the LTS entry won't help you as the root disk is still the same.

### arch-chroot
After we've installed the base system we can change our root to /mnt so that we can do further configurations to the os-disk:

```
arch-chroot /mnt
```

## Install more packages
On top of the base system we are going to install even more packages:

```
pacman -Syy
pacman -S vim intel-ucode dialog terminus-font networkmanager zsh
```

For networking you have multiple options which are very good [documented](https://wiki.archlinux.org/index.php/Network_configuration). I stick to `NetworkManager` but you can also choose something else. 

## Regional Settings
Once the packages are there we go on and configure our regional stuff. We start be generating our locales in `/etc/locale.gen`. Uncomment your appropriate language and then generate the language pack:

```
locale-gen
```

The configured language needs to be set in the `/etc/locale.conf` file as follows:

```
LANG=en_US.UTF-8
```

We installed the terminus-font package so let's make use of it by setting our font in the `/etc/vconsole.conf` file. 
If you want to try a font use `setfont` to change the font, this will not persist over reboots. A list of all available fonts in the system can be seen in `/usr/share/kdb/consolefonts/`

```
FONT=ter-g20b
```

Note: if you get warnings when building the initramfs that say your consolefont is not found, this could be because the installation does not contain the same collection of fonts as the live system. If it's a font beginning with `ter-` install the terminus-font package to get these fonts for your installation.

To set the timezone we just use a hardlink to `/etc/localetime` like so:

```
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
timedatectl set-ntp true
hwclock --systohc
```

I'm using the english (US) Layout so theroretically I don't need to change anything on the keyboard layout. However because I'm from Switzerland and you sometimes need to write something in swiss german I need to type öüä quite a lot. So I switched from standard english (US) to english (Intl., with AltGr dead keys). Anyway here's how you could change the default keyboard layout:

```
localectl list-keymaps 
localectl set-keymap us-acentos
```

or you can also just add your keymap to `/etc/vconsole.conf` as follows:

```
KEYMAP=us
```

## initramfs
As the documentation for arch linux says the initramfs should automatically be generated when installing the base system with pacstrap. But the default HOOKS in the initramfs don't contain support for LVM and the encryption, so wee add them.

I edit `/etc/mkinitcpio.conf` and change the HOOKS line to match that:

```
HOOKS=(base systemd keyboard sd-vconsole autodetect modconf block sd-encrypt lvm2 fsck filesystems)
```

If you want to know more about the order and the hooks for the initramfs I highly recommend reading [this page](https://wiki.archlinux.org/index.php/Mkinitcpio) from the arch linux wiki.

If we change this we need to regenerate the initramfs:

```
mkinitcpio -p linux
# mkinitcpio -p linux-lts
```

## root password
To login after the reboot we need to set a root password:

```
passwd
```

## Hostname
Set the hostname of the machine (chose your own):

```
echo WALL-E > /etc/hostane
```

## bootloader 
At the beginning of the tutorial I said that this installation is a UEFI installation and that I'm going to use systemd-boot as my bootloader. There are mutliple options depending on your preference and your setup. See [here](https://wiki.archlinux.org/index.php/Arch_boot_process) for more information on other options.

First we initizalie the bootloader:

```
systemd-machine-id-setup
bootctl --path=/boot install
```

Now we need to create a bootloader entry. For this we need to know the UUID for the root device. We get it with the following command:

```
uuid=$(blkid --match-tag UUID -o value /dev/sda2)
```

Note that we don't get the UUID of the `root` logical volume but instead of the LUKS parttion. This is fine as we specify the root volume to be used in the bootloader entry.

So let's add an entry to our bootloader:

```
cat <<EOF >/boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd /intel-ucode.img
initrd  /initramfs-linux.img
# initrd /initramfs-linux-lts.img
options rd.luks.name=${uuid}=cryptlvm root=/dev/vgcrypt/root
EOF
```

And we also change the bootloader config to default to our created entry:

```
cat <<EOF >/boot/loader/loader.conf
default arch
#default arch-lts
timeout 0
editor 0
EOF
```

The `editor 0` directive disabled the option to add kernel parameters during boot. The `timeout 0` specified to wait 0 seconds before continuing to boot. So you want see the bootloader with the different options if you don't press space during boot. 

## Keyfile
On my machine I have a problem which causes the keyboard to not work during the boot process even with the keyboard hook in initramfs. 
So I used a workaround which uses a keyfile stored in the initramfs to unlock the LUKS partition. This is not very secure as the initramfs lies on the `/dev/sda1` partition which is not encrypted and anyone with access to the disk could extract the keyfile and then decrypt your data. A better option would be to store the keyfile on a thumb drive and insert this everytime you boot. But I'm not at a point where I think this is necessary for me. If you want to do it you can read everything about it [here](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption).

So that's what I did to fix my problem:

```
dd bs=512 count=4 if=/dev/random of=/keyfile iflag=fullblock
chmod 600 /etc/mykeyfile
cryptsetup luksAddKey /dev/sda2 /keyfile
```

then in the `/etc/mkinitcpio.conf` file I added the following to the FILES and MODULES array:

```
FILES=(/keyfile)
MODULES=(ext4)
```

Regenerated the initramfs:
```
mkinitcpio -p linux
```

and then modified the options line in the boot entry:

```
options rd.luks.name=${uuid}=system rd.luks.key=${uuid}=/keyfile root=/dev/vgcrypt/root
```

## Success?
So this is it for the installation. Now you can `exit` the arch-chroot environment and `reboot` the system to proofe that you successfully installed a working arch linux!

If the installation fails to boot I recommend you boot back into the live system, decrypt the LUKS partition, mount the volumes again and take another look at your boot entry. 
From my experience typos are the most common cause of problems :=) 

## Further configs
We haven't configured `NetworkManager`, we don't have a Desktop Environment or other graphical interface and we don't have `bluetooth`. For those things to work I recommend you to read my [Arch Setup Notes](./arch-setup-notes.md) blog entry. There I noted how to do these things and much more.

## Fruther Reading
* [https://paedubucher.ch/articles/2020-09-26-arch-linux-setup-with-disk-encryption.html](https://paedubucher.ch/articles/2020-09-26-arch-linux-setup-with-disk-encryption.html)
