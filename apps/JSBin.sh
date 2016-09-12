#!/bin/sh

[ $1 = update ] && { npm udpate jsbin; whiptail --msgbox "JSBin updated!" 8 32; break; }
[ $1 = remove ] && { sh sysutils/service.sh remove JS_Bin; npm uninstall jsbin; userdel jsbin; whiptail --msgbox "JSBin  updated!" 8 32; break; }

. sysutils/Node.js.sh

# Add jsbin user
useradd jsbin

# Installation
npm install -g jsbin

# Add systemd process and run the server
sh sysutils/service.sh JSBin "/usr/bin/node /usr/bin/jsbin" / jsbin

whiptail --msgbox "JSBin installed!

Open your browser to http://$URL:3000" 10 64
