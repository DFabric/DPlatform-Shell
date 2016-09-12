#!/bin/sh

#http://support.ghost.org/installing-ghost-linux/
#http://support.ghost.org/how-to-upgrade/
if [ $1 = update ] ;then
  cd /var/www

  download https://ghost.org/zip/ghost-latest.zip "Downloading the Ghost archive..."
  unzip -uo ghost-latest -d ghost-latest

  rm ghost-latest.zip

  cp -rf ghost/content ghost/config.js ghost-latest

  # --unsafe-perm required by node-gyp for the sqlite3 package
  npm install --production --unsafe-perm

  mv ghost ghost-old
  mv ghost-latest ghost

  # Change the owner from root to ghost
  chown -R ghost: /var/www/ghost
  systemctl restart ghost

  whiptail --msgbox "Ghost updated! " 8 48
  exit
fi
[ $1 = remove ] && { sh sysutils/service.sh remove Ghost; rm -rf /var/www/ghost; userdel ghost; whiptail --msgbox "Ghost  updated!" 8 32; break; }

# Define port
port=$(whiptail --title "Ghost port" --inputbox "Set a port number for Ghost" 8 48 "2368" 3>&1 1>&2 2>&3)

. sysutils/Node.js.sh

# Install unzip if not installed
hash unzip 2>/dev/null || $install unzip

# http://support.ghost.org/installing-ghost-linux/
# https://www.howtoinstallghost.com/vps-manual/

## Download and Install Ghost
# Get the latest version of Ghost from Ghost.org
download "https://ghost.org/zip/ghost-latest.zip -O ghost.zip" "Downloading the Ghost archive..."

# Unzip Ghost into the recommended install folder location /var/www/ghost
mkdir -p /var/www/ghost

# Extract the downloaded archive and remove it
unzip ghost.zip -d /var/www/ghost
rm ghost.zip

# Move to the new ghost directory, and install Ghost production dependencies
cd /var/www/ghost

# --unsafe-perm required by node-gyp for the sqlite3 package
npm install --production

## Configure Ghost
cp config.example.js config.js

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

sed -i "s/host: '127.0.0.1'/host: '$access'/" config.js
sed -i "s/port: '2368'/port: '$port'/" config.js

# Change the owner from root to ghost
useradd ghost
chown -R ghost /var/www/ghost

# Add systemd process and run the server
cat > "/etc/systemd/system/ghost.service" <<EOF
[Unit]
Description=The Ghost Blogging Platform
After=network.target
[Service]
Type=simple
WorkingDirectory=/var/www/ghost
ExecStart=/usr/bin/npm start --production
User=ghost
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start Ghost (production environment)
systemctl start ghost
systemctl enable ghost

whiptail --msgbox "Ghost installed!

Visit http://$URL:$port to see your newly setup Ghost blog
Visit http://$URL:$port/ghost and create your admin user to login to the Ghost admin" 12 64
