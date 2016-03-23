#!/bin/sh

# Remove the old server executables
[ $1 = update ] || [ $1 = remove ] && rm -rf ~/Rocket.Chat
[ $1 = remove ] && sh sysutils/services.sh remove Rocket.Chat && whiptail --msgbox "Rocket.Chat removed!" 8 32 && break

# Define port
whiptail --title "Rocket.Chat port" --clear --inputbox "Enter your Rocket.Chat port number. default:[3000]" 8 32 2> /tmp/temp
read port < /tmp/temp
port=${port:-3000}

# Define ReplicaSet
whiptail --yesno --title "[OPTIONAL] Setup MongoDB Replica Set" \
"Rocket.Chat uses the MongoDB replica set OPTIONALLY to improve performance via Meteor Oplog tailing. Would you like to setup the replica set?" 12 48 \
--yes-button No --no-button Yes
[ $? = 1 ] && ReplicaSet=on

. sysutils/MongoDB.sh
. sysutils/Meteor.sh

## Install Dependencies
# SYSTEM CONFIGURATION

cd
# https://github.com/RocketChat/Rocket.Chat.RaspberryPi
if [ $ARCH = arm ]
then
  $install python make g++

  # Download the Rocket.Chat binary for Raspberry Pi
  curl https://cdn-download.rocket.chat/build/rocket.chat-pi-develop.tgz -o rocket.chat.tgz

# https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker
elif [ $ARCH = amd64 ] || [ $ARCH = 86 ]
then
  $install graphicsmagick
  . $DIR/sysutils/NodeJS.sh

  # Install a tool to let us change the node version.
  npm install -g n

  # Meteor needs at least this version of node to work.
  n 0.10.43

  ## Install Rocket.Chat
  # Download Stable version of Rocket.Chat

  curl -L https://rocket.chat/releases/latest/download -o rocket.chat.tgz
else
    whiptail --msgbox "Your architecture $ARCH isn't supported" 8 48 exit 1
fi
tar zxvf rocket.chat.tgz

mv bundle Rocket.Chat
# Install dependencies and start Rocket.Chat
cd Rocket.Chat/programs/server
[ $ARCH = amd64 ] || [ $ARCH = 86 ] && npm install
[ $ARCH = arm ] && ~/meteor/dev_bundle/bin/npm install

rm $HOME/rm rocket.chat.tgz

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

# Create the SystemD service
[ $ARCH = amd64 ] || [ $ARCH = 86 ] && node=/usr/bin/node
[ $ARCH = arm ] && node=$HOME/meteor/dev_bundle/bin/node

cat > "/etc/systemd/system/rocket.chat.service" <<EOF
[Unit]
Description=Rocket.Chat Server
Wants=mongodb.service
After=network.target mongodb.service
[Service]
Type=simple
WorkingDirectory=$HOME/Rocket.Chat
Environment=ROOT_URL=http://$IP:$port/ PORT=$port
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat$ReplicaSet
ExecStart=$node main.js
User=$USER
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable rocket.chat
systemctl start rocket.chat

whiptail --msgbox "Rocket.Chat successfully installed!

Open http://$IP:$port in your browser and register.

The first users to register will be promoted to administrator." 12 64
