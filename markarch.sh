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

echo "Enter your username:"
read USER

echo "Enter your chosen password:"
read PASS

echo -ne "
---------------------------------
-----Configuring Main Drive------
---------------------------------
"
if [ "$DRIVNAME" = "1" ];
then
        DEVNAME="sda"
else
    if [ "$DRIVNAME" = "2" ];
    then
        DEVNAME="nvme0n1p"
    else

# Make sure everything is unmounted
umount -A --recursive /mnt
# For GPT
parted -s /dev/sda mklabel gpt
# Create Partitions
parted -s /dev/sda mkpart primary fat32 1MG 500MB
parted -s /dev/sda mkpart primary linux-swap 500MB 1.5GB
parted -s /dev/sda mkpart primary ext4 2512 100%
parted -s /dev/sda set 1 boot on
# Format new Partitions
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mounting the partitions
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda3 /mnt

echo -ne "
---------------------------------
---Beginning Arch Installation---
---------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware nano sudo grub efibootmgr --noconfirm --needed
# Network and Bluetooth Stuff that'll probably be needed
pacstrap /mnt bluez bluez-utils blueman git networkmanager network-manager-applet wireless_tools --noconfirm --needed
# Can't forget fstab
genfstab -U /mnt >> /mnt/etc/fstab

#echo -ne "
#---------------------------------
#---Installing GRUB Bootloader----
#---------------------------------
#"

exit
