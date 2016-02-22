#!/bin/sh

. sysutils/nodejs.sh

cd
if [ $1 = update ]
  then cd agar.io-clone
  git pull
fi
[ $1 = remove ] && "rm -rf agar.io-clone" && "sh $DIR/sysutils/supervisor remove Agar.io-Clone" && whiptail --msgbox "Agar.io Clone removed!" 8 32 && break

# Cloning the source code from Github
git clone https://github.com/huytd/agar.io-clone

cd agar.io-clone

# Download all the dependencies (socket.io, express, etc.)
npm install

# Add supervisor process and run the server
sh $DIR/sysutils/supervisor.sh Agar.io-Clone "npm start" /root/agar.io-clone

whiptail --msgbox "Agar.io Clone successfully installed!

Run the server: cd agar.io-clone && npm start

The game will then be accessible at http://$IP:3000" 12 64
