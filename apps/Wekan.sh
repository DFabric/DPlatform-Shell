#!/bin/sh

[ $1 = update ] && systemctl stop wekan && rm -rf /home/wekan/bundle
[ $1 = remove ] && sh sysutils/services.sh remove Wekan && userdel -r wekan && whiptail --msgbox "Wekan removed!" 8 32 && break

# https://github.com/wekan/wekan/wiki/Install-and-Update
# Define port
port=$(whiptail --title "Wekan port" --inputbox "Set a port number for Wekan" 8 48 "8081" 3>&1 1>&2 2>&3)

# Add wekan user
useradd -m wekan

# Go to wekan user directory
cd /home/wekan

. sysutils/MongoDB.sh

# Get the latest Wekan release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/wekan/wekan/releases/latest)

# Only keep the version number in the url
ver=${ver#*v}

wget https://github.com/wekan/wekan/releases/download/v$ver/wekan-$ver.tar.gz
# Extract the archive and remove it
tar zxvf wekan-$ver.tar.gz

mv bundle Wekan
rm wekan-$ver.tar.gz

if [ $ARCH = arm ]
then
  # Install Meteor
  # https://github.com/4commerce-technologies-AG/meteor
  git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor

  # Fix curl CA error
  echo insecure > ~/.curlrc
  # Check installed version, try to download a compatible pre-built dev_bundle and finish the installation
  meteor/meteor -v
  rm ~/.curlrc

  $install python make g++

  # Reinstall bcrypt and bson to a newer version is needed
  cd /home/wekan/Wekan/programs/server/npm/npm-bcrypt && /home/wekan/meteor/dev_bundle/bin/npm uninstall bcrypt && /home/wekan/meteor/dev_bundle/bin/npm install bcrypt
  cd /home/wekan/Wekan/programs/server/npm/cfs_gridfs/node_modules/mongodb && /home/wekan/meteor/dev_bundle/bin/npm uninstall bson && /home/wekan/meteor/dev_bundle/bin/npm install bson
elif [ $ARCH = amd64 ] || [ $ARCH = 86 ]
then
  $install graphicsmagick
  . $DIR/sysutils/NodeJS.sh

  # Install Meteor
  . $DIR/sysutils/Meteor.sh

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
[ $ARCH = arm ] && /home/wekan/meteor/dev_bundle/bin/npm install

# Change the owner from root to wekan
chown -R wekan /home/wekan

[ $ARCH = amd64 ] || [ $ARCH = 86 ] && node=/usr/local/n/versions/node/0.10.44/bin/node
[ $ARCH = arm ] && node=/home/wekan/meteor/dev_bundle/bin/node

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
