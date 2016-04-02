#!/bin/sh

# Define port
whiptail --title "StackEdit port" --clear --inputbox "Enter a port number for StackEdit. default:[8050]" 8 32 2> /tmp/temp
read port < /tmp/temp
port=${port:-8050}

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

Open http://$IP:$port in your browser" 10 64
