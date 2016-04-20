#!/bin/sh

if [ $1 = update ]
then
  cd /home/etherpad/etherpad-lite
  git pull
  whiptail --msgbox "Etherpad updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/services.sh remove Etherpad && userdel -r etherpad && whiptail --msgbox "Etherpad removed!" 8 32 && break

# Add etherpad user
useradd -m etherpad

# Go to etherpad user directory
cd /home/etherpad

. sysutils/NodeJS.sh

# gzip, git, curl, libssl develop libraries, python and gcc needed
[ $PKG = deb ] && $install gzip git curl python libssl-dev pkg-config build-essential
[ $PKG = rpm ] && $install gzip git curl python openssl-devel && yum groupinstall "Development Tools"

git clone https://github.com/ether/etherpad-lite

#prepare the enviroment
sh $HOME/etherpad-lite/bin/installDeps.sh

# Add SystemD process and run the server
sh $DIR/sysutils/services.sh Etherpad "/usr/bin/node $HOME/etherpad-lite/node_modules/ep_etherpad-lite/node/server.js" $HOME/

# Change the owner from root to etherpad
chown -R etherpad /home/etherpad

# Create the SystemD service
cat > "/etc/systemd/system/etherdraw.service" <<EOF
[Unit]
Description=Etherpad Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/etherpad/etherpad-lite
ExecStart=/usr/bin/node node_modules/ep_etherpad-lite/node/server.js
User=etherpad
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start etherpad
systemctl enable etherpad

whiptail --msgbox "Etherpad installed!

Open http://$URL:9001 in your browser." 10 64
