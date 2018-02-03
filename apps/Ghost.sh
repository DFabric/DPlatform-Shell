#!/bin/sh

#http://support.ghost.org/installing-ghost-linux/
#http://support.ghost.org/how-to-upgrade/
if [ "$1" = update ] ;then

  # Backuping content and configuration
  systemctl stop ghost
  cd /opt/ghost
  mkdir -p tmp
  cp -r lib/node_modules/ghost/content tmp
  cp lib/node_modules/ghost/core/server/config/env/config.production.json tmp

  # Update ghost
  echo "Updating Ghost"
  export NODE_ENV=production
  npm install ghost -g --unsafe-perm --save --prefix .
  
  # Restore the data and the configurations
  cp -r tmp/content lib/node_modules/ghost
  mv tmp/config.production.json lib/node_modules/ghost/core/server/config/env
  rm -r tmp

  # Migrate the DB
  cd lib/node_modules/ghost
  node node_modules/knex-migrator/bin/knex-migrator migrate

  # Change the owner from root to ghost
  chown -R ghost: /opt/ghost

  systemctl start ghost

  whiptail --msgbox " Ghost updated!" 8 64
  break
fi
[ "$1" = remove ] && { sh sysutils/service.sh remove Ghost; rm -rf /opt/ghost; userdel -rf ghost; whiptail --msgbox "Ghost removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "Ghost port" --inputbox "Set a port number for Ghost" 8 48 "2368" 3>&1 1>&2 2>&3)

. sysutils/Node.js.sh

# Needed to build sqlite3 on ARM (no binaries available)
if [ $ARCHf = arm ]; then
  [ $PKG = deb ] && $install gzip python libssl-dev pkg-config build-essential
  [ $PKG = rpm ] && $install gzip python openssl-devel && yum groupinstall "Development Tools"
fi
# https://docs.ghost.org/docs

# Move to the new ghost directory, and install Ghost production dependencies
mkdir -p /opt/ghost
cd /opt/ghost
export NODE_ENV=production
npm install ghost -g --prefix . --unsafe-perm

# Init the db
cd /opt/ghost/lib/node_modules/ghost
node node_modules/knex-migrator/bin/knex-migrator init

# Ghost configuration
[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

# Change the owner from root to ghost
useradd -rU ghost
chown -R ghost: /opt/ghost

cat > "core/server/config/env/config.production.json" <<EOF
{
    "url": "http://$LOCALIP:$port",
    "server": {
        "host": "$access",
        "port": $port
    },
    "database": {
        "client": "sqlite3",
        "connection": {
            "filename": "content/data/ghost.db"
    },
        "debug": false
    },

    "auth": {
        "type": "password"
    },
    "paths": {
        "contentPath": "content/"
    },
    "logging": {
        "level": "info",
        "rotation": {
            "enabled": true
        },
        "transports": ["file", "stdout"]
    }
}
EOF

# Add a systemd service and run the server
cat > "/etc/systemd/system/ghost.service" <<EOF
[Unit]
Description=The Ghost Blogging Platform
Documentation=https://docs.ghost.org
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/ghost/lib/node_modules/ghost
Environment=GHOST_NODE_VERSION_CHECK=false
ExecStart=/usr/bin/npm start --production
User=ghost
Group=ghost
Restart=always
RestartSec=9

[Install]
WantedBy=multi-user.target
EOF

# Start Ghost (production environment)
systemctl start ghost
systemctl enable ghost

whiptail --msgbox "Ghost installed!

You will probably need to configue Ghost in 'config.js'
Visit http://$URL:$port to see your newly setup Ghost blog
Visit http://$URL:$port/ghost and create your admin user to login to the Ghost admin" 12 64
