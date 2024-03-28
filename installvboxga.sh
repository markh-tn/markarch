#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Please use sudo and try again."
  exit
fi
echo "Installing VirtualBox Guest Additions..."

pacman -S --noconfirm virtualbox-guest-utils
modprobe -a vboxguest vboxsf vboxvideo
systemctl enable vboxservice.service

echo "Installation Complete! Would you like to reboot? [Y/n]"
read REBOOT
if [ "$REBOOT" = "y" ]; then
  reboot now
elif [ "$REBOOT" = "n" ]; then
  echo "Exiting..."
  exit
fi