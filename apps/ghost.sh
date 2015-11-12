#!/bin/sh

. sysutils/nodejs.sh
$install unzip

# http://support.ghost.org/installing-ghost-linux/
# Grab the latest version of Ghost from Ghost.org
curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip

# Unzip Ghost into the folder /var/www/ghost (recommended install location)

mkdir /var/www/
unzip -uo ghost.zip -d /var/www/ghost

# Move to the new ghost directory, and install Ghost (production dependencies only):

cd /var/www/ghost && npm install --production

whiptail --msgbox "Ghost successfully installed!

To start Ghost (production environment), run 'cd /var/www/ghost && npm start --production'

Ghost will now be running on the default ip/port 127.0.0.1:2368.

Visit http://<your-ip-address>:2368 to see your newly setup Ghost blog
Visit http://<your-ip-address>:2368/ghost and create your admin user to login to the Ghost admin" 20 80
