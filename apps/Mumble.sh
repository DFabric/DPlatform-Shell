#!/bin/sh
$install mumble-server

whiptail --msgbox "Mumble successfully installed!

You might need to open port 64738
Address: $IP" 10 48
