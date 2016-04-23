#!/bin/sh

[ $1 = update ] && npm udpate EtherCalc && whiptail --msgbox "EtherCalc updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove EtherCalc && npm uninstall ethercalc && userdel ethercalc && whiptail --msgbox "EtherCalc removed!" 8 32 && break

. sysutils/NodeJS.sh

# Add ethercalc user
useradd -m ethercalc

# Globa installation
npm i -g ethercalc

# Add SystemD process and run the server
sh sysutils/services.sh EtherCalc "/usr/bin/node /usr/bin/ethercalc" / ethercalc

whiptail --msgbox "EtherCalc installed!

Open http://$URL:8000 in your browser." 10 64
