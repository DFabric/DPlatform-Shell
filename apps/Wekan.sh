#!/bin/sh

[ $1 = update ] && systemctl stop wekan && rm -rf /home/wekan/bundle
[ $1 = remove ] && sh sysutils/services.sh remove Wekan && userdel -r wekan && whiptail --msgbox "Wekan removed!" 8 32 && break

# ARM architecture doesn't appear to work
[ $ARCH = arm ] && whiptail --yesno "Your architecture ($ARCH) doesn't appear to be supported yet, cancel the installation?" 8 48
[ $? != 0 ] || break

# https://github.com/wekan/wekan/wiki/Install-and-Update
# Define port
port=$(whiptail --title "Wekan port" --inputbox "Set a port number for Wekan" 8 48 "8081" 3>&1 1>&2 2>&3)

. sysutils/MongoDB.sh
. sysutils/NodeJS.sh

# Install a tool to let us change the node version.
npm install -g n

# Meteor needs at least this version of node to work.
n 0.10.44

# Add wekan user
useradd -m wekan

# Go to wekan user directory
cd /home/wekan

# Get the latest Wekan release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/wekan/wekan/releases/latest)

# Only keep the version number in the url
ver=${ver#*v}

wget https://github.com/wekan/wekan/releases/download/v$ver/wekan-$ver.tar.gz
# Extract the archive and remove it
tar zxvf wekan-$ver.tar.gz
rm wekan-$ver.tar.gz

# Move to the server directory and install the dependencies:
cd bundle/programs/server
/usr/local/n/versions/node/0.10.44/bin/npm install

# Change the owner from root to wekan
chown -R wekan /home/wekan

# Create the SystemD service
cat > "/etc/systemd/system/wekan.service" <<EOF
[Unit]
Description=Wekan Server
Wants=mongodb.service
After=network.target mongodb.service
[Service]
Type=simple
WorkingDirectory=/home/wekan/bundle
ExecStart=/usr/local/n/versions/node/0.10.44/bin/node main.js
Environment=MONGO_URL=mongodb://127.0.0.1:27017/wekan
Environment=ROOT_URL=http://$IP:$port/ PORT=$port
User=wekan
Group=wekan
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start wekan
systemctl enable wekan

whiptail --msgbox "Wekan installed!

Open http://$URL:$portS in your browser" 10 64
