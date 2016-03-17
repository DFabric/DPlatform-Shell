#!/bin/sh

[ $1 = update ] && npm udpate shout && whiptail --msgbox "Shout updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Shout && npm uninstall shout && whiptail --msgbox "Shout removed!" 8 32 && break

. sysutils/NodeJS.sh

# Install
npm install -g shout

whiptail --title "Shout port" --clear --inputbox "Enter your Shout port number. default:[9000]" 8 32 2> /tmp/temp
read port < /tmp/temp
[ "$port" != "" ] && port =" --port $port"

# Add SystemD process and run the server
sh sysutils/services.sh Shout "shout$port" /

whiptail --msgbox "Shout successfully installed!

Open http://$IP:$port in your browser." 10 64
