#!/bin/sh

[ $1 = update ] && npm udpate droppy && whiptail --msgbox "Droppy updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Droppy && npm uninstall droppy && rm -rf /var/www/droppy && whiptail --msgbox "Droppy removed!" 8 32 && break

. sysutils/NodeJS.sh

# Install latest version and dependencies.
npm install -g droppy

# Add SystemD process and run the server
sh sysutils/services.sh Droppy "/usr/bin/node /usr/bin/droppy start --configdir /var/www/droppy/config --filesdir /var/www/droppy/files" /

whiptail --msgbox "Droppy installed!

Open http://$URL:8989 in your browser" 12 64
