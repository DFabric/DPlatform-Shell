#!/bin/sh

# Prerequisites
. sysutils/MongoDB.sh
. sysutils/NodeJS.sh

# https://github.com/sdelements/lets-chat/wiki/Installation
$install python2.7

cd
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

To start Let's Chat:
cd lets-chat && npm start

Open http://$IP:5000 in your browser" 12 48
