#!/bin/sh

[ $1 = update ] && npm udpate jsbin
[ $1 = remove ] && sh sysutils/supervisor remove JS_Bin && npm uninstall jsbin && whiptail --msgbox "JS_Bin removed!" 8 32 && break

# ARM architecture don't appear to work
if [ $ARCH = arm ] || [ $ARCH = armv6 ]
then
  whiptail --yesno "Your architecture ($ARCH) don't appear to be supported yet, continue anyway?" 8 48
  [ $? = 1 ] &&	sed -i "/\bJS_Bin\b/d" installed-apps && break
fi

. sysutils/NodeJS.sh

# Installation
npm install -g jsbin

# Add supervisor process and run the server
sh sysutils/supervisor.sh JS_Bin jsbin /

whiptail --msgbox "JSBin successfully installed!

Open your browser to http://$IP:3000" 12 64
