#!/bin/sh

# Define port
port=$(whiptail --title "StackEdit port" --inputbox "Set a port number for StackEdit" 8 48 "8050" 3>&1 1>&2 2>&3)

. sysutils/NodeJS.sh

# Pre-requisites
cd
git clone https://github.com/benweet/stackedit
npm i -g gulp bower

cd stackedit

# Download development tools
npm install

# Download dependencies
bower install --allow-root

# Add SystemD process
cat > /etc/systemd/system/stackedit.service <<EOF
[Unit]
Description=StackEdit Server
After=network.target
[Service]
Type=simple
WorkingDirectory=$HOME/stackedit
Environment=PORT=$port
ExecStart=/usr/bin/node $HOME/stackedit/server.js
User=$USER
Restart=always
[Install]
WantedBy=multi-user.target
EOF
# Start the service and enable it to start up on boot
systemctl start stackedit
systemctl enable stackedit

whiptail --msgbox "StackEdit installed!

Open http://$URL:$port in your browser" 10 64
