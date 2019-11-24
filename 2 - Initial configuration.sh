#!/bin/bash
# Purpose:	Setup first boot - Starting from Raspian Lite
# Usage:	
# Author:	Timmy93
# Date:		
# Version:	
# Disclaimer:	

: 'TODO BEFORE RUNNING THIS SCRIPT
 - Create Raspian SD card (Download Raspian and flash it using balenaEtcher)
 - Run script: 1 - SD_setup.sh
'

#STEP 0: Variable defining
LOCAL_PATH="/media/pi/HD_joined"
REMOTE_IP="192.168.1.10"
REMOTE_PATH="/media/pi/HD_joined"

#Start changing default password [raspberry]
passwd

#Setup locale - Select: it_IT.UTF-8 en_US.UTF-8 en_GB.UTF-8 - Default: it_IT
sudo dpkg-reconfigure locales

#Update system
sudo apt update
sudo apt upgrade -y

#Install all needed components
sudo apt install nfs-common kodi

#Set up remote HD mounting
sudo install -d -m 0755 -o pi -g www-data $LOCAL_PATH
#Avoid to write when the directory is not mounted
sudo chattr +i $LOCAL_PATH
#Create autoconnect network
SYSTEMD_PATH="/etc/systemd/system"
NETWORK_CONNECTED_SERVICE="network_connected.service"
REMOTE_DISK_MOUNT="remote_disk.mount"

sudo tee -a $SYSTEMD_PATH/$NETWORK_CONNECTED_SERVICE > /dev/null <<EOL
[Unit]
After=network-online.target

[Service]
User=pi
Group=pi
Type=oneshot
ExecStart=/bin/bash -c 'until host google.com; do sleep 1; done'

[Install]
WantedBy=multi-user.target
EOL
sudo chmod 644 $SYSTEMD_PATH/$NETWORK_CONNECTED_SERVICE

#Create automount disk
sudo tee -a $SYSTEMD_PATH/$REMOTE_DISK_MOUNT  > /dev/null <<EOL
[Unit]
Description=The shared remote disk
Wants=network_connected.service
After=network.target network-online.target $NETWORK_CONNECTED_SERVICE

[Mount]
What=$REMOTE_IP:$REMOTE_PATH
Where=$LOCAL_PATH
Type=nfs4
Options=_netdev,auto

[Install]
WantedBy=multi-user.target
EOL
sudo chmod 644 $SYSTEMD_PATH/$REMOTE_DISK_MOUNT
#Enabling automount
sudo systemctl enable $NETWORK_CONNECTED_SERVICE $REMOTE_DISK_MOUNT

#Start kodi on boot
#TODO

#Setup remote disk 
#TODO

#Reboot
sudo reboot
