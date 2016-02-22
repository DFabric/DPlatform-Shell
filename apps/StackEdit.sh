#!/bin/sh

. sysutils/nodejs.sh

# Pre-requisites
cd
git clone https://github.com/benweet/stackedit
npm install bower

cd stackedit

# Download development tools:
npm install

# Download dependencies:
bower install

# Serve StackEdit at http://localhost/:
(export PORT=80 && node server.js)

whiptail --msgbox "StackEdit successfully installed!

To run StackEdit: cd stackedit
(export PORT=80 && node server.js)

Open http://$IP in your browser" 12 64
