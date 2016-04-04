#!/bin/sh

if [ $1 = update ]
then
  cd ~/lets-chat
  git pull
  npm run-script migrate
  whiptail --msgbox "Let's Chat updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/services.sh remove Lets-Chat && rm -rf ~/lets-chat && whiptail --msgbox "Let's Chat removed!" 8 32 && break

# Prerequisites
. sysutils/MongoDB.sh
. sysutils/NodeJS.sh

# https://github.com/sdelements/lets-chat/wiki/Installation
$install python2.7

cd
git clone https://github.com/sdelements/lets-chat
cd lets-chat
npm install

# Create the SystemD service
[ $ARCH = amd64 ] || [ $ARCH = 86 ] && node=/usr/bin/node
[ $ARCH = arm ] && node=$HOME/meteor/dev_bundle/bin/node

cat > "/etc/systemd/system/lets-chat.service" <<EOF
[Unit]
Description=Let's Chat Server
After=network.target mongodb.service
[Service]
Type=simple
WorkingDirectory=$HOME/lets-chat
ExecStart=/usr/bin/npm start
User=$USER
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemctl enable lets-chat
systemctl start lets-chat

whiptail --msgbox "Let's Chat installed!

Open http://$URL:5000 in your browser" 10 64
# Let's Chat - Gitlab Plugin
#npm install lets-chat-gitlab
