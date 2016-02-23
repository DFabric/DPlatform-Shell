#!/bin/sh

. sysutils/nodejs.sh

[ $1 = update ] && npm udpate ethercalc
[ $1 = remove ] && "npm uninstall ethercalc" && "sh $DIR/sysutils/supervisor remove EtherCalc" && whiptail --msgbox "EtherCalc removed!" 8 32 && break

# Globa installation
npm i -g ethercalc

# Add supervisor process and run the server
sh $DIR/sysutils/supervisor.sh EtherCalc ethercalc /

whiptail --msgbox "EtherCalc successfully installed!

Open http://$IP:8000 in your browser." 12 64
