#!/bin/sh

if [ $1 = update ] ;then
  cd /home/etherpad/etherpad-lite
  git pull
  whiptail --msgbox "Etherpad updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/service.sh remove Etherpad && userdel -r etherpad && whiptail --msgbox "Etherpad removed!" 8 32 && break

. sysutils/NodeJS.sh

# Add etherpad user
useradd -m etherpad

# Go to etherpad user directory
cd /home/etherpad

# gzip, git, curl, libssl develop libraries, python and gcc needed
[ $PKG = deb ] && $install gzip python libssl-dev pkg-config build-essential
[ $PKG = rpm ] && $install gzip python openssl-devel && yum groupinstall "Development Tools"

git clone https://github.com/ether/etherpad-lite

#prepare the enviroment
sh $HOME/etherpad-lite/bin/installDeps.sh

# Change the owner from root to etherpad
chown -R etherpad /home/etherpad

# Add SystemD process and run the server
sh $DIR/sysutils/service.sh Etherpad "/usr/bin/node node_modules/ep_etherpad-lite/node/server.js" /home/etherpad/etherpad-lite etherpad

# Start the service and enable it to start on boot
systemctl start etherpad
systemctl enable etherpad

whiptail --msgbox "Etherpad installed!

Open http://$URL:9001 in your browser." 10 64
