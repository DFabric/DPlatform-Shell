#!/bin/sh
$install mumble-server

whiptail --msgbox "Mumble successfully installed!

Address: $DOMAIN
You should need to open port 64738" 12 48
