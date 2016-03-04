#!/bin/sh

if [ $1 = update ]
then
  cd ~/nodebb
  git pull
  whiptail --msgbox "NodeBB updated!" 8 32
  break
fi
[ $1 = remove ] && rm -rf nodebb && whiptail --msgbox "NodeBB removed!" 8 32 && break

. sysutils/NodeJS.sh

# https://docs.nodebb.org/en/latest/installing/os.html

## Installing NodeBB
# Install the base software stack
[ $ARCH = rpm ] && yum -y groupinstall "Development Tools" && $install ImageMagick || $install imagemagick build-essential

# Choice between MongoDB and Redis
whiptail --yesno --title "Database setup" \
"What database would you want to use?
Redis live in RAM. Fast but you can potentially lost some data if your server stops unexpectively
MongoDB is a text based DB. Slower but the data is safer stocked" 12 48 \
--yes-button MongoDB --no-button Redis
[ $? = 0 ] && . sysutils/MongoDB.sh || [ $PKG = deb ] && $install redis-server || $install redis

# Clone the repository
cd
git clone -b v1.x.x https://github.com/NodeBB/NodeBB nodebb

# Obtain all dependencies required by NodeBB via NPM
cd nodebb
npm install --production

# Install NodeBB by running the app with –setup flag
./nodebb setup

[ $ARCH = rpm ] && firewall-cmd --zone=public --add-port=4567/tcp --permanent && firewall-cmd --reload

# Run the NodeBB forum
./nodebb start

whiptail --msgbox "NodeBB successfully installed!

Open http://$IP:4567 in your browser

NodeBB forum directory: cd nodebb
./nodebb {start|restart|stop|log}" 12 64

# TODO
# https://www.npmjs.com/package/nodebb-plugin-blog-comments
