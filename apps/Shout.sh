#!/bin/sh

. sysutils/NodeJS.sh

# Install
npm install -g shout

whiptail --msgbox "Shout successfully installed!

Start the Shout server, for example:
shout start --port 80 --private

shout --help" 12 48
