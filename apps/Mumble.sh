#!/bin/sh

[ $1 = update ] && [ $PKG = deb ] && { apt-get update; $install mumble-server; whitpail --msgbox "Mumble updated!" 8 32; exit; }
[ $1 = update ] && [ $PKG = rpm ] && { yum update; $install mumble-server; whitpail --msgbox "Mumble updated!" 8 32; exit; }
[ $1 = remove ] && { $remove mumble-server; whitpail --msgbox "Mumble removed!" 8 32; exit; }

$install mumble-server
[ $PKG = deb ] && dpkg-reconfigure mumble-server

whiptail --msgbox "Mumble installed!

Address: $IP
port: 64738" 10 48
