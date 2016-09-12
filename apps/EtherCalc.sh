#!/bin/sh

[ $1 = update ] && { npm udpate EtherCalc; whiptail --msgbox "EtherCalc updated!" 8 32; break; }
[ $1 = remove ] && { sh sysutils/service.sh remove EtherCalc; npm uninstall ethercalc; userdel ethercalc; whiptail --msgbox "EtherCalc  updated!" 8 32; break; }

. sysutils/Node.js.sh

# Add ethercalc user
useradd ethercalc

# Globa installation
npm i -g ethercalc

# Add systemd process and run the server
sh sysutils/service.sh EtherCalc "/usr/bin/node /usr/bin/ethercalc" / ethercalc

whiptail --msgbox "EtherCalc installed!

Open http://$URL:8000 in your browser." 10 64
