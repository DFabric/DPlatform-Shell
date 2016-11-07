#!/bin/sh

# Remove the old server executables
[ "$1" = update ] && { systemctl stop rocket.chat; rm -rf /home/rocketchat/Rocket.Chat; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Rocket.Chat; userdel -rf rocketchat; groupdel rocketchat; rm -rf /usr/local/share/node-v0.10.4*; whiptail --msgbox "Rocket.Chat removed." 8 32; break; }

# Define port
port=$(whiptail --title "Rocket.Chat port" --inputbox "Set a port number for Rocket.Chat" 8 48 "3004" 3>&1 1>&2 2>&3)

# Define ReplicaSet
while : ;do
  whiptail --yesno --title "Define the Rocket.Chat MongoDB database" \
  "Rocket.Chat needs a MongoDB database. A new local one will be installed, unless you have already an external database" 10 48 \
  --yes-button Local --no-button External
  case $? in
    0) MONGO_URL=MONGO_URL=mongodb://localhost:27017/rocketchat
    # Define the ReplicaSet
    [ "$1" = "" ] && { . $DIR/sysutils/MongoDB.sh; }
    <<NOT_READY_YET
    whiptail --yesno --title "[OPTIONAL] Setup MongoDB Replica Set" \
    "Rocket.Chat uses the MongoDB replica set OPTIONALLY to improve performance via Meteor Oplog tailing. Would you like to setup the replica set?" 10 48 --defaultno
    # Setup ReplicaSet
    if [ "$?" = 0 ] ;then
      # Mongo 2.4 or earlier
      #if [ $mongo_version -lt 25 ] ;then
      #  echo replSet=001-rs >> /etc/mongod.conf
      # else
      # Mongo 2.6+: using YAML syntax
      echo 'replication:
        replSetName:  "001-rs"' >> /etc/mongod.conf
      # fi
      systemctl restart mongodb

      # Start the MongoDB shell and initiate the replica set
      mongo rs.initiate

      # RESULT EXPECTED
      # {
      #  "info2" : "no configuration explicitly specified -- making one",
      #  "me" : "localhost:27017",
      #  "info" : "Config now saved locally.  Should come online in about a minute.",
      #  "ok" : 1
      # }
      MONGO_URL=MONGO_OPLOG_URL=mongodb://localhost:27017/local"
    fi
NOT_READY_YET
    break;;

    1) MONGO_URL=$(whiptail --inputbox --title "Set your MongoDB instance URL" "\
If you have a MongoDB database, you can enter its URL and use it.
You can also use a MongoDB service provider on the Internet.
You can use a free https://mongolab.com/ database.
Enter your Mongo URL instance (with the brackets removed): \
  " 10 72 "mongodb://:{user}:{password}@{host}:{port}/{datalink}" 3>&1 1>&2 2>&3)
  [ $? = 1 ] || break;;
  esac
done

# https://github.com/4commerce-technologies-AG/meteor
# Special Meteor + Node.js bundle for ARM
[ $ARCHf = arm ] && [ "$1" = "" ] && { . $DIR/sysutils/Meteor.sh; }

# Add rocketchat user
useradd -mrU rocketchat

# Go to rocketchat user directory
cd /home/rocketchat

# Dependencies needed for npm install
[ $PKG = rpm ] && $install gcc-c++ || $install g++
$install python make

# https://github.com/RocketChat/Rocket.Chat.RaspberryPi
if [ $ARCHf = arm ] ;then
  # Download the Rocket.Chat binary for Raspberry Pi
  url=https://cdn-download.rocket.chat/build/rocket.chat-pi-develop.tgz

# https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker
elif [ $ARCHf = x86 ] ;then
  . $DIR/sysutils/Node.js.sh
  [ $PKG = rpm ] && $install epel-release && $install GraphicsMagick || $install graphicsmagick

  # Download Stable version of Rocket.Chat
  url=https://rocket.chat/releases/latest/download
else
    whiptail --msgbox "Your architecture $ARCHf isn't supported" 8 48
fi

# Download the arcive
download "$url -O rocket.chat.tgz" "Downloading the Rocket.Chat archive..."

# Extract the downloaded archive and remove it
extract rocket.chat.tgz "xzf -" "Extracting the files from the archive..."

# Extract the bundle to the current directory
mv bundle/* bundle/.[^.]* .

rm -r bundle rocket.chat.tgz

# Install dependencies and start Rocket.Chat
cd programs/server

[ $ARCHf = x86 ] && npm install && ln -s node_modules/fibers/bin/linux-x64-v8-5.0 node_modules/fibers/bin/linux-x64-v8-5.1
[ $ARCHf = arm ] && /usr/share/meteor/dev_bundle/bin/npm install

# Change the owner from root to rocketchat
chown -R rocketchat: /home/rocketchat

[ $ARCHf = x86 ] && node=/usr/bin/node
[ $ARCHf = arm ] && node=/usr/share/meteor/dev_bundle/bin/node

# Create the systemd service
cat > "/etc/systemd/system/rocket.chat.service" <<EOF
[Unit]
Description=Rocket.Chat Server
Wants=mongod.service
After=network.target mongod.service
[Service]
Type=simple
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=RocketChat
WorkingDirectory=/home/rocketchat
ExecStart=$node main.js
Environment=ROOT_URL=http://$IP:$port/ PORT=$port
Environment=$MONGO_URL
User=rocketchat
Group=rocketchat
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start rocket.chat
systemctl enable rocket.chat

[ "$1" = install ] && state=installed || state=$1d
whiptail --msgbox "Rocket.Chat $state!

Open http://$URL:$port in your browser and register.

The first users to register will be promoted to administrator." 12 64
