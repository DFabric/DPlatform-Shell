#!/bin/sh

[ "$1" = update ] && { cd /srv; npm udpate thelounge; chown -R thelounge: /srv/node_modules/thelounge; whiptail --msgbox "The Lounge updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove TheLounge; userdel -f thelounge; cd /srv; npm uninstall thelounge; whiptail --msgbox "The Lounge removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "The Lounge port" --inputbox "Set a port number for The Lounge" 8 48 "9000" 3>&1 1>&2 2>&3)
port=${port:-9000}

. sysutils/Node.js.sh

# Add thelounge user
useradd -rU thelounge

cd /srv

# Install
npm install thelounge

# Change the owner from root to thelounge
chown -R thelounge: /srv/node_modules/thelounge

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh "The Lounge" "/usr/bin/node /srv/node_modules/thelounge/index.js -P $port" /srv/node_modules/thelounge/node_modules/thelounge thelounge

whiptail --msgbox "The Lounge installed!

Open http://$URL:$port in your browser." 10 64
