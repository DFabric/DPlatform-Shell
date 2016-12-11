#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; break; }
[ "$1" = remove ] && { whiptail --msgbox "Not available yet." 8 32; break; }

curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh > install.sh && bash install.sh

whiptail --msgbox "Ajenti installed!

Open http://$URL:8000 in your browser" 12 64
