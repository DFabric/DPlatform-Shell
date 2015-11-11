#!/bin/sh

#https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker

# SYSTEM CONFIGURATION
. ../sysutils/nodejs.sh
$install git curl
npm install nave -g
nave usemain 0.12.7

curl https://install.meteor.com/ | sh

npm install pm2 -g

if $PKG = rpm
  pm2 startup amazon
else
  pm2 startup
fi

# Check MongoDB version
if grep '2.4' mongo --version 2>/dev/null
  then echo replSet=001-rs >> /etc/mongod.conf
else
  echo "replication:
      replSetName:  "001-rs"" >> /etc/mongod.conf
fi
service mongod restart
mongo
rs.initiate()

# Deploy Rocket.Chat

HOST=your_hostname.com
MONGO_URL=mongodb://localhost:27017/rocketchat
MONGO_OPLOG_URL=mongodb://localhost:27017/local
ROOT_URL=http://$HOST
PORT=3000

mkdir -p /var/www/
mkdir -p /var/log/rocket.chat
cd /var/www/
wget https://github.com/RocketChat/Rocket.Chat/archive/master.tar.gz
tar -xvzf master.tar.gz
mv Rocket.Chat-master rocket.chat

cd ./rocket.chat
meteor build --server "$HOST" --directory .

cd ./bundle/programs/server
npm install

cd ../..

rm -f pm2-rocket-chat.json
echo '{'                                                     > pm2-rocket-chat.json
echo '  "apps": [{'                                         >> pm2-rocket-chat.json
echo '    "name": "rocket.chat",'                           >> pm2-rocket-chat.json
echo '    "script": "/var/www/rocket.chat/bundle/main.js",' >> pm2-rocket-chat.json
echo '    "out_file": "/var/log/rocket.chat/app.log",'      >> pm2-rocket-chat.json
echo '    "error_file": "/var/log/rocket.chat/err.log",'    >> pm2-rocket-chat.json
echo "    \"port\": \"$PORT\","                             >> pm2-rocket-chat.json
echo '    "env": {'                                         >> pm2-rocket-chat.json
echo "      \"MONGO_URL\": \"$MONGO_URL\","                 >> pm2-rocket-chat.json
echo "      \"MONGO_OPLOG_URL\": \"$MONGO_OPLOG_URL\","     >> pm2-rocket-chat.json
echo "      \"ROOT_URL\": \"$ROOT_URL:$PORT\","             >> pm2-rocket-chat.json
echo "      \"PORT\": \"$PORT\""                            >> pm2-rocket-chat.json
echo '    }'                                                >> pm2-rocket-chat.json
echo '  }]'                                                 >> pm2-rocket-chat.json
echo '}'                                                    >> pm2-rocket-chat.json

pm2 start pm2-rocket-chat.json
pm2 save

whiptail --msgbox "Rocket.Chat successfully installed!

Open http://your_hostname.com:3000 in your browser and register.

The first users to register will be promoted to administrator." 16 60
