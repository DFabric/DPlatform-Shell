#!/bin/sh

# Prerequisites
MONGODB_VERSION=26
. sysutils/mongodb.sh
. sysutils/nodejs.sh

$install python2.7

git clone https://github.com/sdelements/lets-chat.git
cd lets-chat
npm install

# Upgrade
#git pull
#npm run-script migrate

# Start
npm start

# Let's Chat - Gitlab Plugin
#npm install lets-chat-gitlab
whiptail --msgbox "Let's Chat successfully installed!

To start Let's Chat: cd lets-chat && npm start

Open http://your_hostname.com:5000 in your browser" 16 60
