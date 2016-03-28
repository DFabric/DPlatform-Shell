#!/bin/sh

$install transmission-daemon transmission-common

whiptail --msgbox "$CHOICE installed!

Open http://$IP:9091 in your browser to access to the web UI" 10 64
