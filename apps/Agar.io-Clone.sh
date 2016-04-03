#!/bin/sh

if [ $1 = update ]
then
  cd ~/agar.io-clone
  git pull
  whiptail --msgbox "Agar.io Clone updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/services.sh remove Agar.io-Clone && rm -rf ~/agar.io-clone && whiptail --msgbox "Agar.io Clone removed!" 8 32 && break

. sysutils/NodeJS.sh

cd
# Cloning the source code from Github
git clone https://github.com/huytd/agar.io-clone

cd agar.io-clone

# Download all the dependencies (socket.io, express, etc.)
npm install

# Add SystemD process and run the server
sh $DIR/sysutils/services.sh Agar.io-Clone "/usr/bin/npm start" $HOME/agar.io-clone

whiptail --msgbox "Agar.io Clone installed!

The game is accessible at http://$URL:3000" 10 64
