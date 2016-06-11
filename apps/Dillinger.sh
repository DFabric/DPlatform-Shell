#!/bin/sh

[ $1 = update ] && { git -C ~/dillinger pull; whiptail --msgbox "Dillinger updated!" 8 32; exit; }
[ $1 = remove ] && { sh sysutils/service.sh remove Dillinger; rm -rf ~/feedbin; whiptail --msgbox "Dillinger removed!" 8 32; exit; }

# ARM architecture doesn't appear to work
[ $ARCHf = arm ]; whitpail --yesno "Your architecture ($ARCHf) doesn't appear to be supported yet, cancel the installation?" 8 48
[ $? != 0 ] || break

. sysutils/Node.js.sh

# Gulp installed globally needed
npm i -g gulp

cd
git clone https://github.com/joemccann/dillinger
cd dillinger
npm i -d
mkdir -p downloads/files/{md,html,pdf}
gulp build --prod

# Add SystemD process and run the server
sh $DIR/sysutils/service.sh Dillinger "/usr/bin/node $HOME/dillinger/app" "$HOME/dillinger
Environment=production"

whiptail --msgbox "Dillinger installed!

Open http://$URL:8080 in your browser" 10 64
