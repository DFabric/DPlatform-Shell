#!/bin/sh

trap 'rm -f choice$$' 0 1 2 5 15 EXIT
whiptail --title Seafile --menu "What torrent web interface would you like to install?" 12 64 2 \
"Deluge" "Lightweight, unobtrusive" \
"Transmission" "Designed for easy, powerful use" \
2> choice$$
read CHOICE < choice$$
case $CHOICE in
  Deluge) $install deluge-web
  port=8112;;
  Transmission) $install transmission-common
  port=9091;;
esac
whiptail --msgbox "$CHOICE successfully installed!

Open http://$IP:$port in your browser to access to the web UI" 10 64
