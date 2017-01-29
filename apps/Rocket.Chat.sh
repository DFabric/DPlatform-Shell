#!/bin/sh

# Remove the old server executables
[ "$1" = update ] && { systemctl stop rocket.chat; rm -rf /var/www/rocketchat; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Rocket.Chat; userdel -f rocketchat; rm -rf /var/www/rocketchat; whiptail --msgbox "Rocket.Chat removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "Rocket.Chat port" --inputbox "Set a port number for Rocket.Chat" 8 48 "3004" 3>&1 1>&2 2>&3)

. sysutils/Node.js.sh

# Define ReplicaSet
while : ;do
  whiptail --yesno --title "Define the Rocket.Chat MongoDB database" \
  "Rocket.Chat needs a MongoDB database. A new local one will be installed, unless you have already an external database" 10 48 \
  --yes-button Local --no-button External
  case $? in
    0) MONGO_URL=MONGO_URL=mongodb://127.0.0.1:27017/rocketchat
    # Define the ReplicaSet
    [ "$1" = "" ] && { . sysutils/MongoDB.sh; }
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

useradd -rU rocketchat

# Go to rocketchat user directory
mkdir -p /var/www/rocketchat
cd /var/www/rocketchat

# Dependencies needed for npm install
if [ $ARCH = arm64 ]
  [ $PKG = rpm ] && $install gcc-c++ || $install g++
  $install python make
fi

# https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker
[ $PKG = rpm ] && $install epel-release && $install GraphicsMagick || $install graphicsmagick

# Download the latest Stable version of Rocket.Chat
download "https://rocket.chat/releases/latest/download -O rocket.chat.tar.gz" "Downloading the Rocket.Chat archive..."

# Extract the downloaded archive and remove it
extract rocket.chat.tar.gz "xzf -" "Extracting the files from the archive..."

# Extract the bundle to the current directory
mv -f bundle/* bundle/.[^.]* .

rm -r bundle rocket.chat.tgz

# Override the recommended Node.js version (4.x) by the current system one
echo $(node -v) > .node_version.txt

# Install dependencies and start Rocket.Chat
cd programs/server

npm install

# Change the owner from root to rocketchat
chown -R rocketchat: /var/www/rocketchat

[ $PKG = deb ] && mongo=mongodb || mongo=mongod
# Create the systemd service
cat > "/etc/systemd/system/rocket.chat.service" <<EOF
[Unit]
Description=Rocket.Chat server
Wants=mongod.service
After=network.target mongod.service
[Service]
Type=simple
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=Rocket.Chat
WorkingDirectory=/var/www/rocketchat
ExecStart=/usr/bin/node main.js
Environment=NODE_ENV=production ROOT_URL=http://$IP:$port/ PORT=$port $MONGO_URL
User=rocketchat
Group=rocketchat
Restart=always
RestartSec=9
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start at boot
systemctl start rocket.chat
systemctl enable rocket.chat

[ "$1" = install ] && state=installed || state=$1d
whiptail --msgbox "Rocket.Chat $state!

Open http://$URL:$port in your browser and register.

The first users to register will be promoted to administrator." 12 64
