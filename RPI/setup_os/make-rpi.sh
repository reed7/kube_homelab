#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [ $# -ne 3 ]; then
  echo "Usage: ./make-rpi.sh <sdcard_device_name> <hostname> <ip-suffix>"
  echo "       ./make-rpi.sh sdb node-1 101"
  echo "       ./make-rpi.sh sdb node-2 102"
  exit 1
fi

export DEV=$1 # Update export DEV= to the device you see on lsblk for your SD card reader, the command is 'diskutil list' on MacO
export IMAGE=~/2018-11-13-raspbian-stretch-lite.img

if [ -z "$SKIP_FLASH" ];
then
  echo "Writing Raspbian Lite image to SD card"
  time dd if=$IMAGE of=/dev/$DEV bs=1M
fi

sync
sleep 1s

echo "Mounting SD card from /dev/$DEV"

mount /dev/${DEV}1 /mnt/rpi/boot
mount /dev/${DEV}2 /mnt/rpi/root

# Add our SSH key
#mkdir -p /mnt/rpi/root/home/pi/.ssh/
#cat ~/.ssh/id_rsa.pub > /mnt/rpi/root/home/pi/.ssh/authorized_keys

echo "Enabling SSH"
cp ssh /mnt/rpi/boot/

echo "Copying WIFI config file"
echo "Trying to backup original wpa_supplicant.conf. You may see a file not found error if the file doesn't exist."
mv /mnt/rpi/boot/wpa_supplicant.conf /mnt/rpi/boot/wpa_supplicant.conf.orig
cp wpa_supplicant.conf /mnt/rpi/boot/

#echo "Disabling password login"
#sed -ie s/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g /mnt/rpi/root/etc/ssh/sshd_config

echo "Setting hostname to $2"

sed -ie s/raspberrypi/$2/g /mnt/rpi/root/etc/hostname
sed -ie s/raspberrypi/$2/g /mnt/rpi/root/etc/hosts

# Reduce GPU memory to minimum
echo "gpu_mem=16" >> /mnt/rpi/boot/config.txt

# Set static IP
cp /mnt/rpi/root/etc/dhcpcd.conf /mnt/rpi/root/etc/dhcpcd.conf.orig

sed s/100/$3/g template-dhcpcd.conf > /mnt/rpi/root/etc/dhcpcd.conf

echo "Unmounting SD Card"

umount /mnt/rpi/boot
umount /mnt/rpi/root

sync
