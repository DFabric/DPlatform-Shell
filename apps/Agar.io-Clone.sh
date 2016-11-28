#!/bin/sh

[ "$1" = update ] && { git -C /home/agario/agar.io-clone pull; chown -R agario: /home/agario; whiptail --msgbox "Agar.io Clone updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Agar.io-Clone; userdel -rf agario; groupdel agario; whiptail --msgbox "Agar.io Clone removed." 8 32; break; }

. sysutils/Node.js.sh

# Add agario user
useradd -mrU agario

# Go to agario user directory
cd /home/agario

# Cloning the source code from Github
git clone https://github.com/huytd/agar.io-clone

cd agar.io-clone

# Download all the dependencies (socket.io, express, etc.)
npm install

# Change the owner from root to agario
chown -R agario: /home/agario

# Create the systemd service
cat > "/etc/systemd/system/agar.io-clone.service" <<EOF
[Unit]
Description=Agar.io Clone Game Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/agario/agar.io-clone
ExecStart=/usr/bin/npm start
User=agario
Group=agario
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start at boot
systemctl start agar.io-clone
systemctl enable agar.io-clone

whiptail --msgbox "Agar.io Clone installed!

The game is accessible at http://$URL:3000" 10 64
