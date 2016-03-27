#!/bin/sh

CHOICE=$(whiptail --title Seafile --menu "What torrent web interface would you like to install?" 12 64 2 \
"Deluge" "Lightweight, unobtrusive" \
"Transmission" "/!\ Designed for easy, powerful use" \
3>&1 1>&2 2>&3)
case $CHOICE in
  Deluge) $install deluged deluge-web
  deluge-web --fork
  port=8112;;
  Transmission) $install transmission-daemon transmission-common
  port=9091;;
esac
whiptail --msgbox "$CHOICE installed!

Open http://$IP:$port in your browser to access to the web UI
Password for Deluge: deluge " 10 64
