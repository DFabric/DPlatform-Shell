#!/bin/sh

[ "$1" = update ] && { cd /srv; npm udpate jsbin; chown -R thelounge: /srv/node_modules/jsbin; whiptail --msgbox "JSBin updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove JSBin; userdel -f jsbin; cd /srv; npm uninstall jsbin; whiptail --msgbox "JSBin removed." 8 32; break; }

. sysutils/Node.js.sh

# Needed for sqlite3
[ $PKG = rpm ] && $install gcc-c++ || $install g++

# Add jsbin user
useradd -rU jsbin

cd /srv
# Installation
npm install jsbin

# Change the owner from root to jsbin
chown -R jsbin: /srv/node_modules/jsbin

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh JSBin "/usr/bin/node /srv/node_modules/jsbin/bin/jsbin" /srv/node_modules/jsbin jsbin

whiptail --msgbox "JSBin installed!

Open your browser to http://$URL:3000" 10 64
