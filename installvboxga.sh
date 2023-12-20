#!/usr/bin/env bash
if [ "$EUID" -ne 0]; then
  echo "This script must be run as root. Please use sudo and try again."
  exit
fi
echo "Installing VirtualBox Guest Additions..."

pacman -S --noconfirm linux-headers virtualbox-guest-utils
modprobe -a vboxguest vboxsf vboxvideo
systemctl enable vboxservice.service

echo "Installation Complete! Would you like to reboot? [Y/n]"
read RBQ
if [ "$RBQ" = "y" ]
then
    reboot now
fi
if [ "$RBQ" = "n" ]
then
    exit
fi