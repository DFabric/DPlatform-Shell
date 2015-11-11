#!/bin/sh

# Prerequisites
# Unofficial MongoDB 2.6.4 for ARM, mongo can not be executed but not a problem, see https://facat.github.io/cross-compile-mongodb-for-arm.html
if [ $ARCH = arm ] && [ $PKG = deb ]
  then cd /etc
  $install p7zip
  wget facat.github.io/mongodb-2.6.4-arm.7z /etc
  7z mongodb-2.6.4-arm.7z
  rm mongodb-2.6.4-arm.7z
  cd /root
elif [ $PKG = deb ]
  then . ../sysutils/mongodb.sh
  $install python2.7
fi
. ../sysutils/nodejs.sh

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
