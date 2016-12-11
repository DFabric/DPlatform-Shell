#!/bin/sh

[ "$1" = update ] && { git -C /home/etherdraw pull; chown -R etherdraw: /home/etherdraw; whiptail --msgbox "EtherDraw updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove EtherDraw; userdel -rf etherdraw; groupdel etherdraw; whiptail --msgbox "EtherDraw removed." 8 32; break; }

. sysutils/Node.js.sh

# Add etherdraw user
useradd -mrU etherdraw

# Go to etherdraw user directory
cd /home/etherdraw

# Install Requirements
[ $PKG = deb ] && $install build-essential libcairo2-dev libpango1.0-dev libgif-dev g++ && { $install libjpeg8-dev || $install libjpeg62-dev; }
[ $PKG = rpm ] && yum groupinstall 'Development Tools' && $install libcairo2-devel libpango1.0-devel libgif-devel gcc-c++ && { $install libjpeg8-devel || $install libjpeg62-devel; }

# Install EtherDraw
git clone https://github.com/JohnMcLear/draw .

# prepare the enviroment
sh bin/installDeps.sh

npm install sqlite3

# Change the owner from root to etherdraw
chown -R etherdraw: /home/etherdraw

# Create the systemd service
cat > /etc/systemd/system/etherdraw.service <<EOF
[Unit]
Description=EtherDraw Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/etherdraw
ExecStart=/usr/bin/node /home/etherdraw/server.js
User=etherdraw
Group=etherdraw
Restart=always
RestartSec=9
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start at boot
systemctl start etherdraw
systemctl enable etherdraw

whiptail --msgbox "EtherDraw installed!

Open http://$URL:9002 in your browser and make a drawing\!" 10 64
