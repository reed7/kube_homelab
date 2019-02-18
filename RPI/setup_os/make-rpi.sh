#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [ -z $1 ]; then
  echo "Usage: ./make-rpi.sh <hostname> <ip-suffix>"
  echo "       ./make-rpi.sh node-1 101"
  echo "       ./make-rpi.sh node-2 102"
  exit 1
fi

export DEV=sdb # Update export DEV= to the device you see on lsblk for your SD card reader, the command is 'diskutil list' on MacO
export IMAGE=2018-11-13-raspbian-stretch-lite.img
export NFS_SRV=192.168.1.76

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
mv /mnt/rpi/boot/wpa_supplicant.conf /mnt/rpi/boot/wpa_supplicant.conf.orig
cp wpa_supplicant.conf /mnt/rpi/boot/

#echo "Disabling password login"
#sed -ie s/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g /mnt/rpi/root/etc/ssh/sshd_config

echo "Setting hostname to $1"

sed -ie s/raspberrypi/$1/g /mnt/rpi/root/etc/hostname
sed -ie s/raspberrypi/$1/g /mnt/rpi/root/etc/hosts

# Reduce GPU memory to minimum
echo "gpu_mem=16" >> /mnt/rpi/boot/config.txt

# Set static IP
cp /mnt/rpi/root/etc/dhcpcd.conf /mnt/rpi/root/etc/dhcpcd.conf.orig

sed s/100/$2/g template-dhcpcd.conf > /mnt/rpi/root/etc/dhcpcd.conf

mkdir -p /mnt/rpi/root/mnt/nfsshare

cat <<EOF >> /mnt/rpi/root/etc/fstab
$NFS_SRV:/nfsshare /mnt/nfsshare nfs defaults 0 0
EOF

echo "Unmounting SD Card"

umount /mnt/rpi/boot
umount /mnt/rpi/root

sync
