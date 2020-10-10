#!/bin/bash
# Purpose:	
# Usage:	
# Author:	Timmy93
# Date:		
# Version:	
# Disclaimer:	

'TODO BEFORE RUNNING THIS SCRIPT
 - Create Raspian SD card (Download Raspian and flash it using balenaEtcher)
'

'STEP
# - Create an empty file called "ssh" inside boot 
# - Setup the wifi: 
		Set the ssid and the psw encoded in wpa config file 
		The file will be the placed on boot: /etc/wpa_supplicant/wpa_supplicant.conf
'

#STEP 0 - Defining the variables

#Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SETTINGS_FILE_NAME="config.sh"
SETTINGS_FILE="$SCRIPT_DIR/$SETTINGS_FILE_NAME"

if [ -f "${SETTINGS_FILE}" ]; then
	source "$SETTINGS_FILE"
else
	echo "[X] Settings file not defined - Create the settings file [${SETTINGS_FILE}]"
fi

BOOT_PARTITION="/media/$USER/boot"
HOME_PI="/media/$USER/rootfs/home/pi"

#STEP 1 - Configuring environment
#Enable ssh
touch $BOOT_PARTITION/ssh
if [ -f "${BOOT_PARTITION}/ssh" ]; then
    echo "[+] Enabled SSH [${BOOT_PARTITION}/ssh]"
else
	echo "[X] Cannot enable SSH - Cannot touch on [${BOOT_PARTITION}]"
	exit
fi

#Import configuration script
SETUP_FILE="${SCRIPT_DIR}/Initial configuration.sh"
SETUP_FILE_IMPORTED="${HOME_PI}/setup.sh"
SETTINGS_FILE_IMPORTED="${HOME_PI}/$SETTINGS_FILE_NAME"
cp "$SETUP_FILE" "$SETUP_FILE_IMPORTED"
cp "$SETTINGS_FILE" "$SETTINGS_FILE_IMPORTED"
chmod +x "${SETUP_FILE_IMPORTED}" "${SETTINGS_FILE_IMPORTED}"
if [ -f "$SETUP_FILE_IMPORTED" ]; then
    echo "[+] Imported setup script"
else
	echo "[X] Cannot import setup script | [${SETUP_FILE}] --> [${SETUP_FILE_IMPORTED}]"
	exit
fi
if [ -f "$SETTINGS_FILE_IMPORTED" ]; then
    echo "[+] Imported settings"
else
	echo "[X] Cannot import settings | [${SETTINGS_FILE}] --> [${SETTINGS_FILE_IMPORTED}]"
	exit
fi

#Setup WiFi
HASH=`wpa_passphrase "$SSID" "$PSW" | grep "^\spsk=.*$" | sed 's/\spsk=//g'`
WIFI_FILE="${BOOT_PARTITION}/wpa_supplicant.conf"
tee $WIFI_FILE > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$COUNTRY

network={
        ssid="$SSID"
        psk=$HASH
}
EOF
if [ -f "$WIFI_FILE" ]; then
    echo "[+] WiFi successfully setupped"
else
	echo "[X] Cannot setup WiFi | [${WIFI_FILE}]"
	exit
fi

#Import kodi backup
KODI_RESTORE="$HOME_PI/kodi_restore.tar"
if [ -f "$KODI_BACKUP" ]; then
	cp "${KODI_BACKUP}" "${KODI_RESTORE}"
	if [ -f "${KODI_RESTORE}" ]; then
		echo "[+] Backup file succesfully imported"
	else
		echo "[X] Cannot import the kodi backup file | [${KODI_RESTORE}]"
	fi
else
	echo "[-] No Kodi backup found - Skipping | [${KODI_BACKUP}]"
fi
