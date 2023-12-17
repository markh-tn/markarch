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
-----Partitioning Main Drive-----
---------------------------------
"
# Make sure everything is unmounted
umount -A --recursive /mnt
# For GPT
parted -s /dev/sda mklabel gpt
# Boot Partition
parted -s /dev/sda mkpart primary fat32 1MG 500MB
# Swap Partition
parted -s /dev/sda mkpart primary linux-swap 500MB 1.5GB
# Root Partition
parted -s /dev/sda mkpart primary ext4 2512 100%
# Enable Boot Flag
parted -s /dev/sda set 1 boot on

echo -ne "
---------------------------------
----Formatting the Partitions----
---------------------------------
"

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





