#!/bin/sh

[ "$1" = update ] && { npm udpate jsbin; whiptail --msgbox "JSBin updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove JSBin; npm uninstall jsbin; userdel -rf jsbin; groupdel jsbin; whiptail --msgbox "JSBin removed." 8 32; break; }

. sysutils/Node.js.sh

# Add jsbin user
useradd -rU jsbin

# Installation
npm install -g jsbin

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh JSBin "/usr/bin/node /usr/bin/jsbin" / jsbin

whiptail --msgbox "JSBin installed!

Open your browser to http://$URL:3000" 10 64
