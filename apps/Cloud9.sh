#!/bin/sh

[ "$1" = update ] && { cd /home/cloud9; git pull origin master; sudo -u cloud9 scripts/install-sdk.sh; whiptail --msgbox "Cloud9 updated!" 8 32; exit;}
[ "$1" = remove ] && { sh sysutils/service.sh remove Cloud9; rm -f /home/cloud9; userdel -rf cloud9; groupdel cloud9; whiptail --msgbox "Cloud9 removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "Cloud9 port" --inputbox "Set a port number for Cloud9" 8 48 "8181" 3>&1 1>&2 2>&3)
port=${:-8181}

. apps/Node.js.sh

$install gcc make sudo

# Add cloud9 user
useradd -rU cloud9

cd /home
git clone https://github.com/c9/core cloud9

# Change the owner from root to ghost
chown -R cloud9: cloud9

# Install the sdk
cd cloud9
sudo -u cloud9 scripts/install-sdk.sh

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh Cloud9 "/usr/bin/node server.js -p $port -l $access -a" /home/cloud9 cloud9

# Start the service and enable it to start at boot
systemctl start cloud9
systemctl enable cloud9

whiptail --msgbox "Cloud9 installed!
Open http://$URL:$port in your browser and register.
The first users to register will be promoted to administrator." 12 64
