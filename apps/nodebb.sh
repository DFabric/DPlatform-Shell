#!/bin/sh
. sysutils/nodejs.sh
. sysutils/mongodb.sh
cd $HOME
# https://docs.nodebb.org/en/latest/installing/os.html

## Installing NodeBB
# Install the base software stack
$install mongodb imagemagick git build-essential

# Clone the repository
git clone -b v0.9.x https://github.com/NodeBB/NodeBB.git nodebb

# Obtain all dependencies required by NodeBB via NPM
cd nodebb
npm install --production

# Install NodeBB by running the app with –setup flag
./nodebb setup

# Run the NodeBB forum
./nodebb start

whiptail --msgbox "NodeBB successfully installed!

Open http://your_ip:4567 in your browser

Run the NodeBB forum: cd nodebb && ./nodebb start" 12 60
# https://www.npmjs.com/package/nodebb-plugin-blog-comments
