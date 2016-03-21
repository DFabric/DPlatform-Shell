#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Mumble updated!" 8 32 && break
[ $1 = remove ] && $remove mumble-server && whiptail --msgbox "Syncthing removed!" 8 32 && break

$install mumble-server
[ $ARCH = deb ] && dpkg-reconfigure mumble-server

whiptail --msgbox "Mumble successfully installed!

You might need to open port 64738
Address: $IP" 10 48
