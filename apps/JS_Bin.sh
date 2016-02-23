#!/bin/sh

. sysutils/nodejs.sh

[ $1 = update ] && npm udpate jsbin
[ $1 = remove ] && "npm uninstall jsbin" && "sh $DIR/sysutils/supervisor remove JS_Bin" && whiptail --msgbox "JS_Bin removed!" 8 32 && break

# Installation
npm install -g jsbin

# Add supervisor process and run the server
sh $DIR/sysutils/supervisor.sh JS_Bin jsbin /

whiptail --msgbox "JSBin successfully installed!

Open your browser to http://$IP:3000" 12 64
