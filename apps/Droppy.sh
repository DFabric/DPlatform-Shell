#!/bin/sh

[ "$1" = update ] && { cd /srv; npm udpate droppy; chown -R ethercalc: /srv/node_modules/droppy; whiptail --msgbox "Droppy updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Droppy; userdel -f droppy; cd /srv; npm uninstall droppy; whiptail --msgbox "Droppy removed." 8 32; break; }

. sysutils/Node.js.sh

# Add droppy user
useradd -rU droppy

cd /srv
# Install latest version and dependencies.
npm install droppy

# Change the owner from root to droppy
chown -R droppy: /srv/node_modules/droppy

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh Droppy "/usr/bin/node /srv/node_modules/droppy/droppy.js start -c /srv/node_modules/droppy/config -f /srv/node_modules/droppy/files" /srv/node_modules/droppy droppy

whiptail --msgbox "Droppy installed!

Open http://$URL:8989 in your browser" 12 64
