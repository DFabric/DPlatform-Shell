#!/bin/sh

# Remove the old server executables
[ "$1" = update ] && { git pull origin master; scripts/install-sdk.sh; chown -R cloud9: /home/cloud9; whiptail --msgbox "Cloud9 updated!" 8 32; exit;}
[ "$1" = remove ] && { sh sysutils/service.sh remove Cloud9; userdel -rf cloud9; groupdel cloud89; whiptail --msgbox "Cloud9  updated!" 8 32; break; }

# Define port
port=$(whiptail --title "Cloud9 port" --inputbox "Set a port number for Cloud9" 8 48 "8181" 3>&1 1>&2 2>&3)
[ "$port" != "" ] && port_arg=" --port $port"

. sysutils/Node.js.sh

# Add cloud9 user
useradd -mrU cloud9

git clone git://github.com/c9/core.git c9sdk
cd c9sdk
scripts/install-sdk.sh

# Change the owner from root to ghost
chown -R cloud9: /home/cloud9

# Add systemd process and run the server
sh sysutils/service.sh Cloud9 "/usr/bin/node server$port_arg" /home/cloud9 cloud9

whiptail --msgbox "Cloud9 installed!

Open http://$URL:$port in your browser and register.

The first users to register will be promoted to administrator." 12 64
