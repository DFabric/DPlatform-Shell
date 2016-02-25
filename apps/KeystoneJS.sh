#!/bin/sh

. sysutils/NodeJS.sh
. sysutils/MongoDB.sh

cd
# Install the generator
npm install -g generator-keystone

# Create project folder
mkdir keystone-site-project
cd keystone-site-project

yo keystone

node keystone

whiptail --msgbox "KeystoneJS successfully installed!

To run your KeystoneJS project: cd keystone-site-project && node keystone

Open http://$IP:3000 to view it in your browser." 12 64
