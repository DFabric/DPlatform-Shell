#!/bin/sh

[ "$1" = update ] && { cd /srv; npm udpate EtherCalc; chown -R ethercalc: /srv/node_modules/ethercalc; whiptail --msgbox "EtherCalc updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove EtherCalc; userdel -f ethercalc; cd /srv; npm uninstall ethercalc; whiptail --msgbox "EtherCalc removed." 8 32; break; }

. sysutils/Node.js.sh

# Defining the port
port=$(whiptail --title "EtherCalc port" --inputbox "Set a port number for EtherCalc" 8 48 "9003" 3>&1 1>&2 2>&3)

# Add ethercalc user
useradd -rU ethercalc

cd /srv
npm i ethercalc

# Create a symlink because ethercalc duplicate the path
ln -rs /srv/node_modules /srv/node_modules/ethercalc/node_modules

# Change the owner from root to ethercalc
chown -R ethercalc: /srv/node_modules/ethercalc

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh EtherCalc "/usr/bin/node /srv/node_modules/ethercalc/app.js --host $access --port $port
Environment=NODE_ENV=production" /srv/node_modules/ethercalc ethercalc

whiptail --msgbox "EtherCalc installed!

Open http://$URL:$port in your browser." 10 64
