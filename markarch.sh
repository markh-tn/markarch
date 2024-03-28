#!/usr/bin/env bash

echo -ne "




"
echo -ne "
---------------------------------
---Mark's Arch Install Script----
---------------------------------
"

echo "The installation will now begin."

echo -ne "Installation Type:
[1] Normal installation (Includes web browser, LibreOffice, media player, and other utilities.)
[2] Libre installation (Similar to normal installation, but with FOSS alternatives)
[3] Minimal installation (Includes web browser and basic utilities.)
"
read INSTYPE

echo -ne "Choose your desktop environment:
[1] Cinnamon
[2] XFCE
[3] LXQT
[4] KDE Plasma
[5] GNOME
[6] None (Install it yourself)
"
read DECHOICE

echo -ne "
What is the name of your Drive?
[1] sda
[2] nvme0n1
"
read DRIVNAME

echo "What will you call this computer?"
read PCNAME

echo "Create your username:"
read USER

echo "Create a secure password:"
read -s PASS

echo -ne "Choose your web browser:
[1] Firefox
[2] Chromium
[3] Vivaldi (Has some proprietary code)
[4] Brave
[5] Librewolf
"
read WEBCHOICE
case "$WEBCHOICE" in
    1) BROWSER="firefox" ;;
    2) BROWSER="chromium" ;;
    3) BROWSER="vivaldi" ;;
    4) BROWSER="brave-bin" ;;
    5) BROWSER="librewolf-bin" ;;
esac

echo "Do you want to install VirtualBox Guest Additions? [Y/n]:"
read VIRBOX

echo -ne "
---------------------------------
-----Configuring Main Drive------
---------------------------------
"
if [ "$DRIVNAME" = "1" ]; then
    DEVNAME="sda"
elif [ "$DRIVNAME" = "2" ]; then
    DEVNAME="nvme0n1"
fi

umount -A --recursive /mnt
parted -s /dev/$DEVNAME mklabel gpt
parted -s /dev/$DEVNAME mkpart primary fat32 1MB 500MB
parted -s /dev/$DEVNAME mkpart primary linux-swap 500MB 1.5GB
parted -s /dev/$DEVNAME mkpart primary ext4 1.5GB 100%
parted -s /dev/$DEVNAME set 1 boot on

if [ "$DEVNAME" = "nvme0n1" ]; then
    DEVNAME="nvme0n1p"
fi
mkfs.fat -F 32 /dev/"$DEVNAME"1
mkswap /dev/"$DEVNAME"2
mkfs.ext4 /dev/"$DEVNAME"3

swapon /dev/"$DEVNAME"2
mount /dev/"$DEVNAME"3 /mnt
mount --mkdir /dev/"$DEVNAME"1 /mnt/boot/efi

echo -ne "
---------------------------------
------Installing Arch Linux------
---------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware linux-headers nano vi sudo grub efibootmgr os-prober mtools inetutils --noconfirm --needed
# Network and Bluetooth Stuff that'll probably be needed
pacstrap /mnt bluez bluez-utils blueman networkmanager network-manager-applet wireless_tools --noconfirm --needed

genfstab -U /mnt >> /mnt/etc/fstab

echo -ne "
---------------------------------
---Installing GRUB Bootloader----
---------------------------------
"
if [ "$DEVNAME" = "nvme0n1p" ]; then
    DEVNAME="nvme0n1"
fi
arch-chroot /mnt /bin/bash <<EOF
grub-install --efi-directory=/boot/efi --target=x86_64-efi /dev/$DEVNAME --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo -ne "
---------------------------------
-Setting up Language and Locale--
---------------------------------
"

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

echo -ne "
---------------------------------
----------Creating User----------
---------------------------------
"

useradd -m -G wheel,storage,audio,power -s /bin/bash $USER
SUSTR="%wheel ALL=(ALL) ALL"
sed -i "/^$SUSTR/s/^# //" "/etc/sudoers"
echo $USER:$PASS | chpasswd
LINE="$USER ALL=(ALL) ALL"
echo "$LINE" | sudo EDITOR='tee -a' visudo
echo root:$PASS | chpasswd
echo "User Creation Finished."

echo -ne "
---------------------------------
------Network Configuration------
---------------------------------
"

sysctl kernel.hostname=$PCNAME
echo "$PCNAME" >> /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1     localhost" >> /etc/hosts
echo "127.0.1.1     $PCNAME.localdomain     $PCNAME" >> /etc/hosts
systemctl enable NetworkManager bluetooth

echo -ne "
---------------------------------
---Audio & Video Configuration---
---------------------------------
"

pacman -S pulseaudio pulseaudio-alsa pavucontrol xorg htop archlinux-wallpaper git --noconfirm --needed

if [ "$DECHOICE" = "1" ]; then
    pacman -S gnome-terminal mousepad cinnamon lightdm lightdm-gtk-greeter ristretto --noconfirm --needed
    systemctl enable lightdm
elif [ "$DECHOICE" = "2" ]; then
    pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm --needed
    systemctl enable lightdm
elif [ "$DECHOICE" = "3" ]; then
    pacman -S lxqt sddm mousepad ristretto --noconfirm --needed
    systemctl enable sddm
elif [ "$DECHOICE" = "4" ]; then
    pacman -S plasma plasma-wayland-session kde-applications sddm --noconfirm --needed
    systemctl enable sddm
elif [ "$DECHOICE" = "5" ]; then
    pacman -S gnome gnome-extra gdm --noconfirm --needed
    systemctl enable gdm
else
    echo "No DE has been selected, skipping.."
fi

if [ "$BROWSER" = "firefox" ] || [ "$BROWSER" = "chromium" ] || [ "$BROWSER" = "vivaldi" ]; then
    pacman -S "$BROWSER" --noconfirm --needed
elif [ "$BROWSER" = "brave-bin" ] || [ "$BROWSER" = "librewolf-bin" ]; then
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman" | sudo tee -a /etc/sudoers >/dev/null
    sudo -u "${USER}" sh -c "cd /home/$USER && git clone https://aur.archlinux.org/${BROWSER}.git && cd ${BROWSER} && makepkg -si --noconfirm"
    rm -rf /home/$USER/$BROWSER
fi

if [ "$INSTYPE" != "2" ]; then
    sed -i '/$USER ALL=(ALL) NOPASSWD: \/usr\/bin\/pacman/d' /etc/sudoers
fi
if [ "$VIRBOX" = "y" ]; then
    mkdir /home/$USER/Desktop
    (cd /home/$USER/Desktop && curl -s https://raw.githubusercontent.com/markh-tn/markarch/main/installvboxga.sh -o VirtualBoxGuestAdditions.sh)
    chmod +x /home/$USER/Desktop/VirtualBoxGuestAdditions.sh
    echo "VirtualBox Guest Additions Install Script is located at /home/$USER/Desktop/VirtualBoxGuestAdditions.sh"
fi

if [ "$INSTYPE" = "3" ]; then
    
echo -ne "
---------------------------------
---Mark's Arch Install Script----
---------------------------------
"
echo "Installation Completed! Remove the installation media and reboot"
echo "Have fun! :)"
exit

elif [ "$INSTYPE" = "1" ]; then
echo -ne "
---------------------------------
--------Installing Extras--------
---------------------------------
"
pacman -S vlc libreoffice-fresh flatpak qbittorrent spotify-launcher neofetch gimp remind discord bitwarden code --noconfirm --needed


elif [ "$INSTYPE" = "2" ]; then
echo -ne "
---------------------------------
-----Installing FOSS Extras------
---------------------------------
"
pacman -S vlc flatpak neofetch gimp remind bitwarden libreoffice-fresh --noconfirm --needed
sudo -u $USER sh -c "cd /home/$USER && git clone https://aur.archlinux.org/spotube-bin.git && cd /home/$USER/spotube-bin && makepkg -si --noconfirm"
sudo -u $USER sh -c "cd /home/$USER && git clone https://aur.archlinux.org/vscodium-bin.git && cd /home/$USER/vscodium-bin && makepkg -si --noconfirm"
rm -rf /home/$USER/vscodium-bin /home/$USER/spotube-bin
sed -i '/$USER ALL=(ALL) NOPASSWD: \/usr\/bin\/pacman/d' /etc/sudoers

fi

echo -ne "
---------------------------------
---Mark's Arch Install Script----
---------------------------------
"
echo "Installation Completed! Remove the installation media and reboot"
echo "Have fun! :)"
EOF
exit
