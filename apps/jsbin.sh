#!/bin/sh
. sysutils/nodejs.sh
npm install -g jsbin
jsbin

whiptail --msgbox "JSBin successfully installed!

Open your browser to http://$IP:3000" 12 64
