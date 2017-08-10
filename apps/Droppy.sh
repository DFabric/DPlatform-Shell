#!/bin/sh

if [ "$1" = update ] ;then
  cd /opt
  npm install -g droppy --prefix /opt/droppy
  chown -R droppy: /opt/droppy
  whiptail --msgbox "Droppy updated!" 8 32
  break
elif [ "$1" = remove ] ;then
  sh sysutils/service.sh remove Droppy
  rm -rf /opt/droppy
  userdel -f droppy
  whiptail --msgbox "Droppy removed." 8 32
  break
fi
. sysutils/Node.js.sh

# Add droppy user
useradd -rU droppy

# Install laest version and dependencies.
mkdir -p /opt/droppy /opt/droppy/etc/droppy /opt/droppy/srv/droppy-data
npm install -g droppy --prefix /opt/droppy

# Create the config file
cat > /opt/droppy/etc/droppy/congig.json <<EOF
{
  "listeners" : [
    {
      "host": ["0.0.0.0", "::"],
      "port": 8989,
      "protocol": "http"
    }
  ],
  "public": false,
  "timestamps": true,
  "linkLength": 5,
  "logLevel": 2,
  "maxFileSize": 0,
  "updateInterval": 1000,
  "pollingInterval": 0,
  "keepAlive": 20000,
  "allowFrame": false,
  "readOnly": false,
  "ignorePatterns": [],
  "watch": true
}
EOF

# Change the owner from root to droppy
chown -R droppy: /opt/droppy

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh Droppy "/usr/bin/node /opt/droppy/bin/droppy start -c /opt/droppy/etc/droppy -f /opt/droppy/srv/droppy-data" /opt/droppy droppy

whiptail --msgbox "Droppy installed!

Open http://$URL:8989 in your browser" 12 64
