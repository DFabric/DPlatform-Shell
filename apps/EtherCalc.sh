#!/bin/sh

[ $1 = update ] && npm udpate EtherCalc && whiptail --msgbox "EtherCalc updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/supervisor remove EtherCalc && npm uninstall EtherCalc && whiptail --msgbox "EtherCalc removed!" 8 32 && break

. sysutils/NodeJS.sh

# Globa installation
npm i -g ethercalc

# Add supervisor process and run the server
sh sysutils/supervisor.sh EtherCalc ethercalc /

whiptail --msgbox "EtherCalc successfully installed!

Open http://$IP:8000 in your browser." 12 64
