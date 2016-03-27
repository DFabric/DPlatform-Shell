#!/bin/sh

[ $1 = update ] && npm udpate jsbin
[ $1 = remove ] && sh sysutils/services.sh remove JS_Bin && npm uninstall jsbin && whiptail --msgbox "JS_Bin removed!" 8 32 && break

# ARM architecture doesn't appear to work
[ $ARCH = arm ] && whiptail --yesno "Your architecture ($ARCH) doesn't appear to be supported yet, cancel the installation?" 8 48
[ $? != 0 ] || break

. sysutils/NodeJS.sh

# Installation
npm install -g jsbin

# Add SystemD process and run the server
sh sysutils/services.sh JS_Bin jsbin /

whiptail --msgbox "JSBin installed!

Open your browser to http://$IP:3000" 12 64
