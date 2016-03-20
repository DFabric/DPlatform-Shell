#!/bin/sh
$install mumble-server
[ $ARCH = deb ] && dpkg-reconfigure mumble-server

whiptail --msgbox "Mumble successfully installed!

You might need to open port 64738
Address: $IP" 10 48
