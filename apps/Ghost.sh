#!/bin/sh

. sysutils/NodeJS.sh

$install unzip

# http://support.ghost.org/installing-ghost-linux/
# https://www.howtoinstallghost.com/vps-manual/

## Download and Install Ghost
# Get the latest version of Ghost from Ghost.org
curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip

# Unzip Ghost into the recommended install folder location /var/www/ghost
mkdir -p /var/www/
unzip -uo ghost.zip -d /var/www/ghost
rm ghost.zip

# Move to the new ghost directory, and install Ghost production dependencies
cd /var/www/ghost && npm install --production

## Configure Ghost
cp config.example.js config.js
sed -i "s/host: '127.0.0.1',/host: '0.0.0.0',/g" config.js

# Start Ghost (production environment)
cd /var/www/ghost && npm start --production

whiptail --msgbox "Ghost successfully installed!

To start Ghost (production environment), run 'cd /var/www/ghost && npm start --production'

Visit http://$IP:2368 to see your newly setup Ghost blog
Visit http://$IP:2368/ghost and create your admin user to login to the Ghost admin" 16 80
