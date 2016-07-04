#!/bin/sh

[ $1 = update ] && { npm udpate jsbin; whiptail --msgbox "JSBin updated!" 8 32; exit; }
[ $1 = remove ] && { sh sysutils/service.sh remove JS_Bin; npm uninstall jsbin; userdel jsbin; whiptail --msgbox "JSBin removed!" 8 32; exit; }

. sysutils/Node.js.sh

# Add jsbin user
useradd -m jsbin

# Installation
npm install -g jsbin

# Add SystemD process and run the server
sh sysutils/service.sh JSBin "/usr/bin/node /usr/bin/jsbin" / jsbin

whiptail --msgbox "JSBin installed!

Open your browser to http://$URL:3000" 10 64
