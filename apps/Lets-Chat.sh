#!/bin/sh

[ $1 = update ] && { git -C /home/letschat/lets-chat pull; npm run-script migrate; whitpail --msgbox "Let's Chat updated!" 8 32; exit; }
[ $1 = remove ] && { sh sysutils/service.sh remove Lets-Chat; userdel -r letschat; whitpail --msgbox "Let's Chat removed!" 8 32; exit; }

# Prerequisites
. sysutils/MongoDB.sh
. sysutils/Node.js.sh

# Add letschat user
useradd -m letschat

# Go to letschat user directory
cd /home/letschat

# https://github.com/sdelements/lets-chat/wiki/Installation
$install python2.7

git clone https://github.com/sdelements/lets-chat
cd lets-chat
npm install

# Change the owner from root to letschat
chown -R letschat /home/letschat

# Create the SystemD service
cat > "/etc/systemd/system/lets-chat.service" <<EOF
[Unit]
Description=Let's Chat Server
Wants=mongodb.service
After=network.target mongodb.service
[Service]
Type=simple
WorkingDirectory=/home/letschat/lets-chat
ExecStart=/usr/bin/npm start
User=letschat
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl enable lets-chat
systemctl start lets-chat

whiptail --msgbox "Let's Chat installed!

Open http://$URL:5000 in your browser" 10 64
# Let's Chat - Gitlab Plugin
#npm install lets-chat-gitlab
