#!/bin/sh

. sysutils/nodejs.sh

# Install
npm install -g shout

whiptail --msgbox "Shout successfully installed!

Start the Shout server, for example:
shout start --port 80 --private

shout --help" 16 60
