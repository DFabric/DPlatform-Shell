#!/bin/sh

if [ $1 = update ]
then
  cd ~/etherpad-lite
  git pull
  whiptail --msgbox "Etherpad updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/services.sh remove Etherpad && rm -rf ~/etherpad-lite && whiptail --msgbox "Etherpad removed!" 8 32 && break

. sysutils/NodeJS.sh

cd
# gzip, git, curl, libssl develop libraries, python and gcc needed
[ $PKG = deb ] && $install gzip git curl python libssl-dev pkg-config build-essential
[ $PKG = rpm ] && $install gzip git curl python openssl-devel && yum groupinstall "Development Tools"

git clone https://github.com/ether/etherpad-lite

#prepare the enviroment
sh $HOME/etherpad-lite/bin/installDeps.sh

# Add SystemD process and run the server
sh $DIR/sysutils/services.sh Etherpad "/usr/bin/node $HOME/etherpad-lite/node_modules/ep_etherpad-lite/node/server.js" $HOME/etherpad-lite

whiptail --msgbox "Etherpad successfully installed!

Open http://$IP:9001 in your browser." 10 64
