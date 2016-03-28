#!/bin/sh

$install transmission-daemon

sed -i '/"rpc-whitelist-enabled": true/"rpc-whitelist-enabled": false/g' /etc/transmission-daemon/settings.json
#~/.config/transmission-daemon/settings.json

whiptail --msgbox "$CHOICE installed!

Open http://$IP:9091 in your browser to access to the web UI
User Name: transmission | Password: transmission" 10 64
