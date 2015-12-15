#!/bin/sh

. sysutils/mongodb.sh
. sysutils/nodejs.sh

# https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker

## Install Dependencies
# SYSTEM CONFIGURATION
$install git curl graphicsmagick

# Install a tool to let us change the node version.
npm install -g n

# Meteor needs at least this version of node to work.
n 0.10.40

## Install Rocket.Chat
# Download Stable version of Rocket.Chat
curl -O https://s3.amazonaws.com/rocketchatbuild/rocket.chat-master.tgz

tar zxvf rocket.chat-*.tgz

mv bundle Rocket.Chat
cd Rocket.Chat/programs/server
npm install
cd ../..

# Set environment variables
whiptail --title "Rocket.Chat port" --clear --inputbox "Enter your Rocket.Chat port. default:[3000]" 8 32

port=${x%?}
port=${port:-3000}
export ROOT_URL=http://$IP:$port/
export MONGO_URL=mongodb://localhost:27017/rocketchat
export PORT=$port

# Run the server
node main.js

## Setup MongoDB Replica Set
# Check MongoDB version
mongo_version=$(mongo --version)
# Keep the version numver
mongo_version=${mongo_version: 23}
mongo_version=${mongo_version%.*}
# Concatenate major and minor version numbers together
mongo_major=${mongo_version%.*}
mongo_minor=${mongo_version#*.}
mongo_version=$mongo_major$mongo_minor

# Mongo 2.4 or earlier
if [ $mongo_version -lt 25 ]
  then echo replSet=001-rs >> /etc/mongod.conf
# Mongo 2.6+: using YAML syntax
else
  echo "replication:
      replSetName:  "001-rs"" >> /etc/mongod.conf
fi
service mongod restart
mongo

# Start the MongoDB shell and initiate the replica set
mongo rs.initiate()

<<RESULT_EXPECTED
{
  "info2" : "no configuration explicitly specified -- making one",
  "me" : "localhost:27017",
  "info" : "Config now saved locally.  Should come online in about a minute.",
  "ok" : 1
}
RESULT_EXPECTED

export MONGO_OPLOG_URL=mongodb://localhost:27017/local

whiptail --msgbox "Rocket.Chat successfully installed!

Open http://$IP:$port in your browser and register.

The first users to register will be promoted to administrator." 12 64
