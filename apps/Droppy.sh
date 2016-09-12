#!/bin/sh

[ $1 = update ] && { npm udpate droppy; whiptail --msgbox "Droppy updated!" 8 32; break; }
[ $1 = remove ] && { sh sysutils/service.sh remove Droppy; npm uninstall droppy; rm -rf /var/www/droppy; userdel -r droppy; whiptail --msgbox "Droppy  updated!" 8 32; break; }

. sysutils/Node.js.sh

# Add droppy user
useradd -m droppy

# Install latest version and dependencies.
npm install -g droppy

# Add systemd process and run the server
sh sysutils/service.sh Droppy "/usr/bin/node /usr/bin/droppy start --configdir /var/www/droppy/config --filesdir /var/www/droppy/files" / droppy

whiptail --msgbox "Droppy installed!

Open http://$URL:8989 in your browser" 12 64
