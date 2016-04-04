#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Ghost && rm -rf /var/www/ghost && whiptail --msgbox "Ghost removed!" 8 32 && break

. sysutils/NodeJS.sh

# Install unzip if not installed
hash unzip 2>/dev/null || $install unzip

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
cd /var/www/ghost
npm install --production

## Configure Ghost
cp config.example.js config.js
sed -i "s/host: '127.0.0.1',/host: '0.0.0.0',/g" config.js

# Change the owner from root to ghost
chown -R ghost:ghost /var/www/ghost

# Add SystemD process and run the server
cat > "/etc/systemd/system/ghost.service" <<EOF
[Unit]
Description=The Ghost Blogging Platform
After=network.target
[Service]
Type=simple
WorkingDirectory=/var/www/ghost
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
User=ghost
Group=ghost
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start Ghost (production environment)
systemctl start ghost
systemctl enable ghost

whiptail --msgbox "Ghost installed!

Visit http://$URL:2368 to see your newly setup Ghost blog
Visit http://$URL:2368/ghost and create your admin user to login to the Ghost admin" 12 64
