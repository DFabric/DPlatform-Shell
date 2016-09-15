#!/bin/sh

[ $1 = update ] && { git -C /home/stackedit pull; whiptail --msgbox "StackEdit updated!" 8 32; break; }
[ $1 = remove ] && { sh sysutils/service.sh remove StackEdit; userdel -rf stackedit; groupdel stackedit; whiptail --msgbox "StackEdit  updated!" 8 32; break; }

# Define port
port=$(whiptail --title "StackEdit port" --inputbox "Set a port number for StackEdit" 8 48 "8050" 3>&1 1>&2 2>&3)

. sysutils/Node.js.sh

# Create stackedit user
useradd -rU stackedit

# Pre-requisites
git clone https://github.com/benweet/stackedit /home/stackedit
npm i -g gulp bower

# Go to the stackedit user directory
cd /home/stackedit

# Download development tools
npm install

# Download dependencies
bower install --allow-root

# Change the owner from root to git
chown -R stackedit: /home/stackedit

# Add systemd process
cat > /etc/systemd/system/stackedit.service <<EOF
[Unit]
Description=StackEdit Server
After=network.target
[Service]
Type=simple
Environment=PORT=$port
WorkingDirectory=/home/stackedit
ExecStart=/usr/bin/node server.js
User=stackedit
group=stackedit
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start up on boot
systemctl start stackedit
systemctl enable stackedit

whiptail --msgbox "StackEdit installed!

Open http://$URL:$port in your browser" 10 64
