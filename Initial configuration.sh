#!/bin/bash
# Purpose:	Setup first boot - Starting from Raspian Lite
# Usage:	
# Author:	Timmy93
# Date:		
# Version:	
# Disclaimer:	

'TODO BEFORE RUNNING THIS SCRIPT
 - Create Raspian SD card (Download Raspian and flash it using balenaEtcher)
 - Run script: 1 - SD_setup.sh
'

#Variable definition and check
CANARY="/home/pi/autosetup_completed"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETTINGS_FILE="$SCRIPT_DIR/config.sh"

if [ -f "${SETTINGS_FILE}" ]; then
	source "$SETTINGS_FILE"
else
	echo "[X] Settings file not defined - Create the settings file [${SETTINGS_FILE}]"
fi

if [ -f "$CANARY" ]; then
	echo "[+] Already setupped, exiting from setup!"
	echo "[+] Enjoy!"
	exit 0
else
	touch "$CANARY"
fi

#Start changing default password [raspberry]
passwd
echo "[+] Changed default password"

#Setup locale - Select: it_IT.UTF-8 en_US.UTF-8 en_GB.UTF-8 - Default: it_IT
sudo dpkg-reconfigure locales
echo "[+] Setting locales"

#Update system
sudo apt update
sudo apt upgrade -y
echo "[+] Updating raspberry"

#Install all needed components
sudo apt install nfs-common kodi

#Set up remote HD mounting
sudo install -d -m 0755 -o pi -g www-data $LOCAL_PATH
#Avoid to write when the directory is not mounted
sudo chattr +i $LOCAL_PATH
#Create autoconnect network
SYSTEMD_PATH="/etc/systemd/system"
NETWORK_CONNECTED_SERVICE="network_connected.service"
REMOTE_DISK_MOUNT=`echo ${LOCAL_PATH:1}.mount | sed 's$/$-$g'`

sudo tee $SYSTEMD_PATH/$NETWORK_CONNECTED_SERVICE > /dev/null <<EOL
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
echo "[+] Added connection at startup"

#Create automount disk
sudo tee $SYSTEMD_PATH/$REMOTE_DISK_MOUNT  > /dev/null <<EOL
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
sudo systemctl daemon-reload
sudo systemctl enable $NETWORK_CONNECTED_SERVICE $REMOTE_DISK_MOUNT
echo "[+] Added remote disk"

#Import kodi backup
KODI_RESTORE="/home/pi/kodi_restore.tar"
KODI_DIR="/home/pi/.kodi"
if [ -f "$KODI_RESTORE" ]; then
	rm -rf "$KODI_DIR" 2> /dev/null
	tar -xf "$KODI_RESTORE" -C "$KODI_DIR"
	if [ -d "${KODI_DIR}/.kodi" ]; then
		mv "${KODI_DIR}/.kodi/*" "${KODI_DIR}/"
		rm -rf "$KODI_DIR/.kodi" 2> /dev/null
		echo "[+] Solved nested backup directory problem"
	fi
	if [ -d "${KODI_DIR}" ]; then
		echo "[+] Kodi backup succesfully restored"
	else
		echo "[X] Cannot restore the kodi backup file | [${KODI_RESTORE}] --> [${KODI_DIR}]"
	fi
else
	echo "[-] No Kodi backup to restore - Skipping | [${KODI_RESTORE}]"
fi


#Start kodi on boot
(crontab -l 2>/dev/null; echo "@reboot kodi --standalone")| crontab -
echo "[+] Added kodi at startup"

#Reboot
rm "$SETTINGS_FILE"
if [ -f "${SETTINGS_FILE}" ]; then
	echo "[+] Removed settings file with your secrets"
fi
echo "[+] Setup completed, rebooting..."
sudo reboot
