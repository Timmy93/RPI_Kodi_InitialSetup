#!/bin/bash
# Purpose:	
# Usage:	
# Author:	Timmy93
# Date:		
# Version:	
# Disclaimer:	

: 'TODO BEFORE RUNNING THIS SCRIPT
 - Create Raspian SD card (Download Raspian and flash it using balenaEtcher)
'

: 'STEP
# - Create an empty file called "ssh" inside boot 
# - Setup the wifi: 
		Set the ssid and the psw encoded in wpa config file 
		The file will be the placed on boot: /etc/wpa_supplicant/wpa_supplicant.conf
'

#STEP 0 - Defining the variables
#WiFI Name
SSID="YOUR_SSID"
#WiFi Password
PSW="YOUR_PSW"
#WiFi nation / Nation where the WiFi is working
COUNTRY="IT"
#The path to the boot partition inside the SD card
BOOT_PARTITION="/media/YOUR_USER/boot"

HASH=`wpa_passphrase "$SSID" "$PSW" | grep "^\spsk=.*$" | sed 's/\spsk=//g'`

#STEP 1 - Enable ssh
touch $BOOT_PARTITION/ssh

#STEP 1 - Setup WiFi
tee $BOOT_PARTITION/wpa_supplicant.conf > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$COUNTRY

network={
        ssid="$SSID"
        psk="$HASH"
}
EOF
