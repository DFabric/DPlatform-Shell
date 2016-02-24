#!/bin/sh

. sysutils/nodejs.sh

cd
if [ $1 = update ]
then
  cd agar.io-clone
  git pull
  whiptail --msgbox "Agar.io Clone updated!" 8 32
  break
fi
[ $1 = remove ] && "rm -rf agar.io-clone" && "sh $DIR/sysutils/supervisor remove Agar.io-Clone" && whiptail --msgbox "Agar.io Clone removed!" 8 32 && break

# Cloning the source code from Github
git clone https://github.com/huytd/agar.io-clone

cd agar.io-clone

# Download all the dependencies (socket.io, express, etc.)
npm install

# Add supervisor process and run the server
sh $DIR/sysutils/supervisor.sh Agar.io-Clone "npm start" $HOME/agar.io-clone

whiptail --msgbox "Agar.io Clone successfully installed!

The game is accessible at http://$IP:3000" 10 64
