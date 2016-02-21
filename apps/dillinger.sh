#!/bin/sh

. sysutils/nodejs.sh

# Gulp installed globally needed
npm i -g gulp

cd
git clone https://github.com/joemccann/dillinger dillinger
cd dillinger
npm i -d
mkdir -p downloads/files/{md,html,pdf}
gulp build --prod
NODE_ENV=production node app

whiptail --msgbox "Dillinger successfully installed!

Open http://$IP:8080 in your browser" 10 64
