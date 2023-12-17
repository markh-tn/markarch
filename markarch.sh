#!/usr/bin/env bash
echo "---------------------------------"
echo "---Mark's Arch Install Script----"
echo "---------------------------------"

echo "The installation will now begin."

echo "Enter the name of the drive you want Arch installed on (example: sda, nvme0n1). If you don't know, quit this script and run lsblk:"
read DISK

echo "Enter your username:"
read USER

echo "Enter your chosen password:"
read PASS

echo "---------------------------------"
echo "-----Partitioning Main Drive-----"
echo "---------------------------------"
# For GPT
parted -s /dev/$DISK mklabel gpt
# Boot Partition
parted -s /dev/$DISK mkpart primary fat32 2000 2512
# Swap Partition
parted -s /dev/$DISK mkpart primary linux-swap 512 1024
# Root Partition
parted -s /dev/$DISK mkpart primary ext4 2512 100%
# Enable Boot Flag
parted -s /dev/$DISK set 2 boot on



