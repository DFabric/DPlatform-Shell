#!/bin/sh

[ $1 = update ] && npm udpate shout && whiptail --msgbox "Shout updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Shout && npm uninstall shout && whiptail --msgbox "Shout removed!" 8 32 && break

. sysutils/NodeJS.sh

# Install
npm install -g shout

port=$(whiptail --title "Shout port" --inputbox "Set a port number for Shout" 8 48 "9000" 3>&1 1>&2 2>&3)

[ "$port" != "" ] && port =" --port $port"

# Add SystemD process and run the server
sh sysutils/services.sh Shout "/usr/bin/node /usr/bin/shout$port" /

whiptail --msgbox "Shout installed!

Open http://$URL:$port in your browser." 10 64
