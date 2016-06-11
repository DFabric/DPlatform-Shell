#!/bin/sh

[ $1 = update ] && { npm udpate shout; whitpail --msgbox "Shout updated!" 8 32; exit; }
[ $1 = remove ] && { sh sysutils/service.sh remove Shout; npm uninstall shout; userdel shout; whitpail --msgbox "Shout removed!" 8 32; exit; }

# Define port
port=$(whiptail --title "Shout port" --inputbox "Set a port number for Shout" 8 48 "9000" 3>&1 1>&2 2>&3)
[ "$port" != "" ] && port =" --port $port"

. sysutils/Node.js.sh

# Add shout user
useradd -m shout

# Install
npm install -g shout

# Add SystemD process and run the server
sh sysutils/service.sh Shout "/usr/bin/node /usr/bin/shout$port" / shout

whiptail --msgbox "Shout installed!

Open http://$URL:$port in your browser." 10 64
