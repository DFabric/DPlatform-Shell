#!/bin/sh

if [ $1 = update ] ;then
  cd /home/nodebb
  git pull
  ./nodebb upgrade
  whiptail --msgbox "NodeBB updated and upgraded!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/service.sh remove NodeBB && userdel -r nodebb && whiptail --msgbox "NodeBB removed!" 8 32 && break

# https://docs.nodebb.org/en/latest/installing/os.html

## Installing NodeBB
# Install the base software stack
[ $PKG = rpm ] && yum -y groupinstall "Development Tools" && $install ImageMagick || $install imagemagick build-essential

# Choice between MongoDB and Redis
whiptail --yesno --title "Database setup" \
"What database would you want to use?
Redis - In memory database. Fast but consumme RAM
MongoDB is a text document based DB. Database on disk but slower
If you don't know, take the default MongoDB" 12 48 \
--yes-button MongoDB --no-button Redis
if [ $? = 0 ] ;then
  . sysutils/MongoDB.sh
  DB=mongod
elif [ $PKG = deb ] ;then
  $install redis-server
  DB=redis
else
  $install redis
  DB=redis
fi

. sysutils/NodeJS.sh

# Create a nodebb user
useradd -m nodebb

# Go to nodebb user directory
cd /home/nodebb

# Clone the repository
git clone -b v1.x.x https://github.com/NodeBB/NodeBB .

# Obtain all dependencies required by NodeBB via NPM
npm install --production

# Install NodeBB by running the app with –setup flag
#cat > config.json
<<EOF
{
    "url": "http://[::]:4567",
    "secret": "",
    "database": "mongo",
    "mongo": {
        "host": "127.0.0.1",
        "port": "27017",
        "username": "",
        "password": "",
        "database": "0"
    }
}
EOF

./nodebb setup

# In Centos6/7 allowing port through the firewall is needed
[ $PKG = rpm ] && firewall-cmd --zone=public --add-port=4567/tcp --permanent && firewall-cmd --reload

# Change the owner from root to nodebb
chown -R nodebb /home/nodebb

# Add SystemD process
cat > /etc/systemd/system/nodebb.service <<EOF
[Unit]
Description=NodeBB Forum Server
After=network.target $DB.service
[Service]
Type=simple
WorkingDirectory=/home/nodebb
ExecStart=/usr/bin/node /app.js
User=nodebb
Restart=always
[Install]
WantedBy=multi-user.target
EOF
# Start the service and enable it to start up on boot
systemctl start nodebb
systemctl enable nodebb

whiptail --msgbox "NodeBB installed!

Open http://$URL:4567 in your browser" 10 64

# TODO
# https://www.npmjs.com/package/nodebb-plugin-blog-comments
