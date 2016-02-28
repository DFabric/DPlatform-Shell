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
. sysutils/MongoDB.sh

# https://docs.nodebb.org/en/latest/installing/os.html

## Installing NodeBB
# Install the base software stack
$install mongodb imagemagick git build-essential

# Clone the repository
cd
git clone -b v0.9.x https://github.com/NodeBB/NodeBB nodebb

# Obtain all dependencies required by NodeBB via NPM
cd nodebb
npm install --production

# Install NodeBB by running the app with –setup flag
./nodebb setup

# Run the NodeBB forum
./nodebb start

whiptail --msgbox "NodeBB successfully installed!

Open http://$IP:4567 in your browser

Run the NodeBB forum: cd nodebb && ./nodebb start" 12 64

# TODO
# https://www.npmjs.com/package/nodebb-plugin-blog-comments
