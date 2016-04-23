#!/bin/sh

[ $1 = update ] && systemctl stop wekan && rm -rf /home/wekan/bundle
[ $1 = remove ] && sh sysutils/services.sh remove Wekan && userdel -r wekan && whiptail --msgbox "Wekan removed!" 8 32 && break

# https://github.com/wekan/wekan/wiki/Install-and-Update
# Define port
port=$(whiptail --title "Wekan port" --inputbox "Set a port number for Wekan" 8 48 "8081" 3>&1 1>&2 2>&3)


. sysutils/MongoDB.sh
. sysutils/Meteor.sh

# Add wekan user
useradd -m wekan

# Go to wekan user directory
cd /home/wekan

# Get the latest Wekan release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/wekan/wekan/releases/latest)

# Only keep the version number in the url
ver=${ver#*v}

curl -OL https://github.com/wekan/wekan/releases/download/v$ver/wekan-$ver.tar.gz
# Extract the downloaded archive and remove it
(pv -n wekan-$ver.tar.gz | tar xzf -) 2>&1 | whiptail --gauge "Extracting the files from the downloaded archive..." 6 64 0

mv bundle Wekan
rm wekan-$ver.tar.gz

if [ $ARCH = arm ] ;then
  $install python make g++

  # Reinstall bcrypt and bson to a newer version is needed
  cd /home/wekan/Wekan/programs/server/npm/npm-bcrypt && /usr/share/meteor/dev_bundle/bin/npm uninstall bcrypt && /usr/share/meteor/dev_bundle/bin/npm install bcrypt
  cd /home/wekan/Wekan/programs/server/npm/cfs_gridfs/node_modules/mongodb && /usr/share/meteor/dev_bundle/bin/npm uninstall bson && /usr/share/meteor/dev_bundle/bin/npm install bson
elif [ $ARCH = amd64 ] || [ $ARCH = 86 ] ;then
  $install graphicsmagick
  . $DIR/sysutils/NodeJS.sh

  # Install a tool to let us change the node version.
  npm install -g n

  # Meteor needs at least this version of node to work.
  n 0.10.44
else
    whiptail --msgbox "Your architecture $ARCH isn't supported" 8 48
fi

# Move to the server directory and install the dependencies:
cd /home/wekan/Wekan/programs/server

[ $ARCH = amd64 ] || [ $ARCH = 86 ] && /usr/local/n/versions/node/0.10.44/bin/npm install
[ $ARCH = arm ] && /usr/share/meteor/dev_bundle/bin/npm install

# Change the owner from root to wekan
chown -R wekan /home/wekan

[ $ARCH = amd64 ] || [ $ARCH = 86 ] && node=/usr/local/n/versions/node/0.10.44/bin/node
[ $ARCH = arm ] && node=/usr/share/meteor/dev_bundle/bin/node

# Create the SystemD service
cat > "/etc/systemd/system/wekan.service" <<EOF
[Unit]
Description=Wekan Server
Wants=mongodb.service
After=network.target mongodb.service
[Service]
Type=simple
WorkingDirectory=/home/wekan/Wekan
ExecStart=$node main.js
Environment=MONGO_URL=mongodb://127.0.0.1:27017/wekan
Environment=ROOT_URL=http://$IP:$port/ PORT=$port
User=wekan
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start wekan
systemctl enable wekan

whiptail --msgbox "Wekan installed!

Open http://$URL:$port in your browser" 10 64
