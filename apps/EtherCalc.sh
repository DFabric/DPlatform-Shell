#!/bin/sh

[ $1 = update ] && npm udpate EtherCalc && whiptail --msgbox "EtherCalc updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove EtherCalc && npm uninstall EtherCalc && whiptail --msgbox "EtherCalc removed!" 8 32 && break

. sysutils/NodeJS.sh

# Globa installation
npm i -g ethercalc

# Add SystemD process and run the server
sh sysutils/services.sh EtherCalc ethercalc /

whiptail --msgbox "EtherCalc installed!

Open http://$IP:8000 in your browser." 12 64
