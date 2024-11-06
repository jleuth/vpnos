#!/bin/sh

# Install base
apk update
apk add openrc
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
rc-update add networking default
rc-update add local default

# Install TTY
apk add agetty

# Setting up shell
apk add shadow
apk add bash bash-completion
chsh -s /bin/bash
echo -e "helloworld\nhelloworld" | passwd
apk del -r shadow

# Install SSH
apk add openssh
rc-update add sshd default

# Extra stuff
apk add mtd-utils-ubi
apk add bottom
apk add neofetch

# VPNOS: Install necessary packages
echo "Updating package lists and installing required packages..."
sudo apk add -y python3 python3-pip python3-pil libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7 libtiff5 python3-smbus i2c-tools wireguard
pip3 install requests luma.oled
mkdir ~/.setup

# VPNOS: allow user to interface with oled hardware
sudo usermod -a -G spi,gpio,i2c root

# VPNOS: install pivpn unnattended
cd .setup
curl https://gist.githubusercontent.com/jleuth/0ddf047cd386deadc11c5acf90563031/raw/861f2f0674962adf860c34a48353c1da804e4cd6/vpnos.conf > vpnos.conf
curl -L https://install.pivpn.io > install.sh
chmod +x install.sh
./install.sh --unattended vpnos.conf

# VPNOS: Download and run the Python script to display the IP on the OLED
echo "Running display script..."
curl -O https://gist.githubusercontent.com/jleuth/cdd6534e4f0421750f8658df01b08615/raw/8a553b7676f7d22f4cfed2806d419f6d0182b325/displayip.py > displayip.py
python3 displayip.py

# Clear apk cache
rm -rf /var/cache/apk/*

# Packaging rootfs
for d in bin etc lib sbin usr; do tar c "$d" | tar x -C /extrootfs; done
for dir in dev proc root run sys var oem userdata; do mkdir /extrootfs/${dir}; done
