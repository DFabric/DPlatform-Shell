#!/bin/sh
$install mumble-server

whiptail --msgbox "Mumble successfully installed!

Address: $IP
You should need to open port 64738" 12 48
