#!/bin/sh

$install transmission-daemon

#sed -i 's/"rpc-whitelist": "127.0.0.1"/"rpc-whitelist": "127.0.0.1"/' /etc/transmission-daemon/settings.json

sed -i 's/"rpc-whitelist-enabled": true/"rpc-whitelist-enabled": false/' /etc/transmission-daemon/settings.json
#~/.config/transmission-daemon/settings.json

whiptail --msgbox "$CHOICE installed!

Open http://$URL:9091 in your browser to access to the web UI
User Name: transmission | Password: transmission" 10 64
