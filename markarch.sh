#!/usr/bin/env bash
echo "---------------------------------"
echo "---Mark's Arch Install Script----"
echo "---------------------------------"

echo "The installation will now begin."

echo "This script is assuming your main drive is sda. If it isnt please quit this script."
read

echo "Enter your username:"
read USER

echo "Enter your chosen password:"
read PASS

echo "---------------------------------"
echo "-----Partitioning Main Drive-----"
echo "---------------------------------"
# For GPT
parted -s /dev/sda mklabel gpt
# Boot Partition
parted -s /dev/sda mkpart primary fat32 2000 2512
# Swap Partition
parted -s /dev/sda mkpart primary linux-swap 1024 1024
# Root Partition
parted -s /dev/sda mkpart primary ext4 2512 100%
# Enable Boot Flag
parted -s /dev/sda set 2 boot on



