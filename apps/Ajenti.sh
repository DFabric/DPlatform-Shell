#!/bin/sh

curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh > install.sh && bash install.sh

whiptail --msgbox "Ajenti successfully installed!

Open https://$IP:8000 in your browser" 12 64
