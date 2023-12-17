#!/usr/bin/env bash

echo -ne "
---------------------------------
---Mark's Arch Install Script----
---------------------------------
"

echo "The installation will now begin."

echo "This script is assuming your main drive is sda. If it isnt please quit this script."
read

echo "Enter your username:"
read USER

echo "Enter your chosen password:"
read PASS

echo -ne "
---------------------------------
-----Configuring Main Drive------
---------------------------------
"
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

echo -ne "
---------------------------------
---Installing GRUB Bootloader----
---------------------------------
"

grub-install --target=x86_64-efi --efi-directory=/boot /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg







