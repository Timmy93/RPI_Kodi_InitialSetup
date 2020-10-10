# RPI_Kodi_InitialSetup
Automatize the creation of my Raspberry PI 4 media center


## Description
The script is composed by the following parts:
1. **config.sh**: This file **MUST** be compiled with the required information. Some of the required information are: 
	- *Wifi SSID/Password/Country*: to automatically connect the device to a wifi
	- *BOOT_PARTITION*: the path to the SD where the configuration files will be placed.
	
2. **SD_setup.sh**: this is the script to run **before** turning on the raspberry. Enables SSH and other configurations.
	
3. **Initial configuration.sh**: this script will install necessary software, connect external devices and restore backups on the raspberry.


## Troubleshooting
- *No space left on device*: During the image flash not all the SD card space was allocated.
To solve this problem is sufficient to open disk utility umount all mounted partition and extend *rootfs* partiotion.
- *Not booting - Failed to open device: 'sdcard'*: Leave at least 2 MB at the end of the disk.
