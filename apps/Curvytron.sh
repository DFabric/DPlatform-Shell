#!/bin/sh

[ $1 = update ] && { git -C /home/curvytron pull; git -C /home/curvytron reset --hard; }
[ $1 = remove ] && { sh sysutils/service.sh remove Curvytron; userdel -r curvytron; whiptail --msgbox "Curvytron  updated!" 8 32; break; }

# Define port
port=$(whiptail --title "Curvytron port" --inputbox "Set a port number for Curvytron" 8 48 "8086" 3>&1 1>&2 2>&3)

. sysutils/Node.js.sh

# Add curvytron user
useradd curvytron

## Installation
# Clone the repository
git clone https://github.com/Curvytron/curvytron /home/curvytron

# Go to the curvytron user directory
cd /home/curvytron

# Duplicate config.json.sample to config.json to setup a custom configuration,
cp config.json.sample config.json

sed -i "s/port: 8080/port: $port/" bin/curvytron.js

# Install dependencies
npm install -g bower gulp

npm install
npm install node-sass@next
npm install gulp-sass@2.3.1

bower install --allow-root

# Build the game
gulp

# Change the owner from root to agario
chown -R curvytron /home/curvytron

# Add systemd process and run the server
sh sysutils/service.sh Curvytron "/usr/bin/node /home/curvytron/bin/curvytron.js" /home/curvytron curvytron

# Start the service and enable it to start on boot
systemctl start curvytron
systemctl enable curvyton

whiptail --msgbox "Curvytron installed!

The game is accessible at http://$URL:$port" 10 64
