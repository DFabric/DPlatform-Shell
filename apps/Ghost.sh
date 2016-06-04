#!/bin/sh

#http://support.ghost.org/installing-ghost-linux/
#http://support.ghost.org/how-to-upgrade/
if [ $1 = update ] ;then
  cd /var/www/ghost

  wget https://ghost.org/zip/ghost-latest.zip 2>&1 | \
  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --gauge "Downloading the archive..." 6 64 0
  (pv -n ghost-latest.zip | unzip -uo - -d ghost) 2>&1 | whiptail --gauge "Extracting the files from the archive..." 6 64 0

  rm ghost-latest.zip
  mv ghost/core ghost/index.js ghost/*.md ghost/*.json .
  rm -r ghost

  # --unsafe-perm required by node-gyp for the sqlite3 package
  npm install --production --unsafe-perm

  # Change the owner from root to ghost
  chown -R ghost /var/www/ghost
  systemctl restart ghost
  whiptail --msgbox "Ghost updated!" 8 32
  exit
fi
[ $1 = remove ] && { sh sysutils/service.sh remove Ghost; rm -rf /var/www/ghost; userdel ghost; whitpail --msgbox "Ghost removed!" 8 32; exit; }

# Define port
port=$(whiptail --title "Ghost port" --inputbox "Set a port number for Ghost" 8 48 "2368" 3>&1 1>&2 2>&3)

. sysutils/NodeJS.sh

# Install unzip if not installed
hash unzip 2>/dev/null || $install unzip

# http://support.ghost.org/installing-ghost-linux/
# https://www.howtoinstallghost.com/vps-manual/

## Download and Install Ghost
# Get the latest version of Ghost from Ghost.org
wget https://ghost.org/zip/ghost-latest.zip -O ghost.zip 2>&1 | \
stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --gauge "Downloading the archive..." 6 64 0

# Unzip Ghost into the recommended install folder location /var/www/ghost
mkdir -p /var/www/

# Extract the downloaded archive and remove it
unzip - -d /var/www/ghost
rm ghost.zip

# Move to the new ghost directory, and install Ghost production dependencies
cd /var/www/ghost

# --unsafe-perm required by node-gyp for the sqlite3 package
npm install --production --unsafe-perm

## Configure Ghost
cp config.example.js config.js

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

sed -i "s/url: 'my-ghost-blog.com'/url: '$URL:$port'/" config.js
sed -i "s/host: '127.0.0.1'/host: '$access'/" config.js
sed -i "s/port: '2368'/port: '$port'/" config.js

# Change the owner from root to ghost
useradd ghost
chown -R ghost /var/www/ghost

# Add SystemD process and run the server
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
