#!/bin/sh

# Remove the old server executables
[ $1 = update ] && systemctl stop rocket.chat && rm -rf /home/rocketchat/Rocket.Chat
[ $1 = remove ] && sh sysutils/services.sh remove Rocket.Chat && userdel -r rocketchat && whiptail --msgbox "Rocket.Chat removed!" 8 32 && break

# Define port
port=$(whiptail --title "Rocket.Chat port" --inputbox "Set a port number for Rocket.Chat" 8 48 "3004" 3>&1 1>&2 2>&3)

# Define ReplicaSet
whiptail --yesno --title "[OPTIONAL] Setup MongoDB Replica Set" \
"Rocket.Chat uses the MongoDB replica set OPTIONALLY to improve performance via Meteor Oplog tailing. Would you like to setup the replica set?" 12 48 \
--yes-button No --no-button Yes
[ $? = 1 ] && ReplicaSet=on

. sysutils/MongoDB.sh
## Install Dependencies
# SYSTEM CONFIGURATION

# Add rocketchat user
useradd -m rocketchat

# Go to rocketchat user directory
cd /home/rocketchat

# https://github.com/RocketChat/Rocket.Chat.RaspberryPi
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

  # Download the Rocket.Chat binary for Raspberry Pi
  curl https://cdn-download.rocket.chat/build/rocket.chat-pi-develop.tgz -o rocket.chat.tgz

# https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker
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

  ## Install Rocket.Chat
  # Download Stable version of Rocket.Chat

  curl -L https://rocket.chat/releases/latest/download -o rocket.chat.tgz
else
    whiptail --msgbox "Your architecture $ARCH isn't supported" 8 48
fi

# Extract the archive and remove it
tar zxvf rocket.chat.tgz

mv bundle Rocket.Chat
rm rocket.chat.tgz
# Install dependencies and start Rocket.Chat
cd Rocket.Chat/programs/server

[ $ARCH = amd64 ] || [ $ARCH = 86 ] && /usr/local/n/versions/node/0.10.44/bin/npm install
[ $ARCH = arm ] && /home/rocketchat/meteor/dev_bundle/bin/npm install

# Setup ReplicaSet
if [ "$ReplicaSet" = on ]
then
  # Mongo 2.4 or earlier
  if [ $mongo_version -lt 25 ]
    then echo replSet=001-rs >> /etc/mongod.conf
  # Mongo 2.6+: using YAML syntax
  else
    echo 'replication:
        replSetName:  "001-rs"' >> /etc/mongod.conf
  fi
  service mongod restart

  # Start the MongoDB shell and initiate the replica set
  mongo rs.initiate

  # RESULT EXPECTED
  # {
  #  "info2" : "no configuration explicitly specified -- making one",
  #  "me" : "localhost:27017",
  #  "info" : "Config now saved locally.  Should come online in about a minute.",
  #  "ok" : 1
  # }
  $ReplicaSet="
Environment=MONGO_OPLOG_URL=mongodb://localhost:27017/local"
fi

# Change the owner from root to rocketchat
chown -R rocketchat /home/rocketchat

[ $ARCH = amd64 ] || [ $ARCH = 86 ] && node=/usr/local/n/versions/node/0.10.44/bin/node
[ $ARCH = arm ] && node=/home/rocketchat/meteor/dev_bundle/bin/node

# Create the SystemD service
cat > "/etc/systemd/system/rocket.chat.service" <<EOF
[Unit]
Description=Rocket.Chat Server
Wants=mongodb.service
After=network.target mongodb.service
[Service]
Type=simple
StandardOutput=syslog
SyslogIdentifier=RocketChat
WorkingDirectory=/home/rocketchat/Rocket.Chat
ExecStart=$node main.js
Environment=ROOT_URL=http://$IP:$port/ PORT=$port
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat$ReplicaSet
User=rocketchat
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start rocket.chat
systemctl enable rocket.chat

[ $ARCH != arm ] && whiptail --msgbox "Rocket.Chat installed!

Open http://$URL:$port in your browser and register.

The first users to register will be promoted to administrator." 12 64
