#!/bin/sh
cd $HOME
. sysutils/nodejs.sh
$install git

# Cloning the source code from Github
git clone https://github.com/huytd/agar.io-clone

cd agar.io-clone

# Download all the dependencies (socket.io, express, etc.)
npm install

# Run the server
npm start

whiptail --msgbox "Agar.io Clone successfully installed!

Run the server: cd agar.io-clone && npm start

The game will then be accessible at http://localhost:3000." 12 64
