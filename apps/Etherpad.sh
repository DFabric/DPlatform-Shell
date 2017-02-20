#!/bin/sh

[ "$1" = update ] && { git -C /home/etherpad pull; chown -R etherpad: /home/etherpad; whiptail --msgbox "Etherpad updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Etherpad; userdel -rf etherpad; whiptail --msgbox "Etherpad removed." 8 32; break; }

. sysutils/Node.js.sh

# Defining the port
port=$(whiptail --title "Etherpad port" --inputbox "Set a port number for Etherpad" 8 48 "9001" 3>&1 1>&2 2>&3)

# Create etherpad user directory
# Add etherpad user
useradd -rU etherpad

# gzip, git, curl, libssl develop libraries, python and gcc needed
[ $PKG = deb ] && $install gzip python libssl-dev pkg-config build-essential
[ $PKG = rpm ] && $install gzip python openssl-devel && yum groupinstall "Development Tools"

cd /home
git clone https://github.com/ether/etherpad-lite etherpad

cp settings.json.template settings.json

[ $IP = $LOCALIP ] && sed -i "s/0.0.0.0/$IP/" settings.json
sed -i "s/9001/$port/" settings.json

# Relace dirty db by SQlite
sed -i 's/"dbType" : "dirty"/"dbType" : "sqlite"/' settings.json
sed -i 's/var\/dirty.db/var\/sqlite.db/' settings.json

#prepare the enviroment
sh /home/etherpad/bin/installDeps.sh

npm install sqlite3

# Change the owner from root to etherpad
chown -R etherpad: /home/etherpad

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh Etherpad "/usr/bin/node /home/etherpad/node_modules/ep_etherpad-lite/node/server.js" /home/etherpad etherpad

whiptail --msgbox "Etherpad installed!

Open http://$URL:$port in your browser." 10 64
