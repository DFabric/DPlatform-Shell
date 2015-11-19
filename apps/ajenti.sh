#!/bin/sh
$install curl
curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh > install.sh && bash install.sh

# Start the service:
#/etc/init.d/ajenti start

whiptail --msgbox "Ajenti successfully installed!

Open http://$DOMAIN:8000 in your browser" 12 48
