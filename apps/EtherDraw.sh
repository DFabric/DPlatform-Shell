#!/bin/sh

[ $1 = update ] && { git -C /home/etherdraw/draw pull; chown -R etherdraw: /home/etherdraw; whiptail --msgbox "EtherDraw updated!" 8 32; break; }
[ $1 = remove ] && { sh sysutils/service.sh remove EtherDraw; userdel -rf etherdraw; groupdel etherdraw; whiptail --msgbox "EtherDraw  updated!" 8 32; break; }

# ARM architecture doesn't appear to work
[ $ARCHf = arm ]; whiptail --yesno "Your architecture ($ARCHf) doesn't appear to be supported yet, cancel the installation?" 8 48
[ $? != 0 ] || break

. sysutils/Node.js.sh

# Add etherdraw user
useradd -mrU etherdraw

# Go to etherdraw user directory
cd /home/etherdraw

# Install Requirements
$install libcairo2-dev libpango1.0-dev libgif-dev build-essential g++
$install libjpeg8-dev || $install libjpeg62-dev

# Install EtherDraw
git clone https://github.com/JohnMcLear/draw

#prepare the enviroment
cd draw
sh bin/installDeps.sh

# Change the owner from root to etherdraw
chown -R etherdraw: /home/etherdraw

# Create the systemd service
cat > "/etc/systemd/system/etherdraw.service" <<EOF
[Unit]
Description=EtherDraw Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/etherdraw/draw
ExecStart=/usr/bin/node server.js
User=etherdraw
Group=etherdraw
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start etherdraw
systemctl enable etherdraw

whiptail --msgbox "EtherDraw installed!

Open http://$URL:9002 in your browser and make a drawing\!" 10 64
