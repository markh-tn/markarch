#!/usr/bin/env bash

echo -ne "
---------------------------------
---Mark's Arch Install Script----
---------------------------------
"

echo "The installation will now begin."

echo -ne "
What is the name of your Drive?
[1] sda
[2] nvme0n1
"
read DRIVNAME

# I'll uncomment the stuff below once I get most of the script working
#echo "Enter your username:"
#read USER

#echo "Enter your chosen password:"
#read PASS

echo -ne "
---------------------------------
-----Configuring Main Drive------
---------------------------------
"
if [ "$DRIVNAME" = "1" ]
then
   DEVNAME="sda"
fi

if [ "$DRIVNAME" = "2" ]
then
    DEVNAME="nvme0n1"
fi
# Make sure everything is unmounted
umount -A --recursive /mnt
# For GPT
parted -s /dev/$DEVNAME mklabel gpt
# Create Partitions
parted -s /dev/$DEVNAME mkpart primary fat32 1MB 500MB
parted -s /dev/$DEVNAME mkpart primary linux-swap 500MB 1.5GB
parted -s /dev/$DEVNAME mkpart primary ext4 1.5GB 100%
parted -s /dev/$DEVNAME set 1 boot on
# Format new Partitions
if [ "$DEVNAME" = "nvme0n1" ]
then
    DEVNAME="nvme0n1p"
fi
mkfs.fat -F 32 /dev/"$DEVNAME"1
mkswap /dev/"$DEVNAME"2
mkfs.ext4 /dev/"$DEVNAME"3

# Mounting the partitions
mount --mkdir /dev/"$DEVNAME"1 /mnt/boot
swapon /dev/"$DEVNAME"2
mount /dev/"$DEVNAME"3 /mnt

echo -ne "
---------------------------------
------Installing Arch Linux------
---------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware nano sudo grub efibootmgr --noconfirm --needed
# Network and Bluetooth Stuff that'll probably be needed
pacstrap /mnt bluez bluez-utils blueman git networkmanager network-manager-applet wireless_tools --noconfirm --needed
# Can't forget fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo -ne "
---------------------------------
---Installing GRUB Bootloader----
---------------------------------
"
mkdir /mnt/boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /mnt/boot

exit