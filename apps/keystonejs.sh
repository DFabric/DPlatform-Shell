#!/bin/sh

. sysutils/nodejs.sh
. sysutils/mongodb.sh

# Install the generator
npm install -g generator-keystone

# Create project folder
mkdir my-test-project
cd my-test-project

yo keystone

node keystone

whiptail --msgbox "KeystoneJS successfully installed!

To run your KeystoneJS project: node keystone

Open http://localhost:3000 to view it in your browser." 16 60
