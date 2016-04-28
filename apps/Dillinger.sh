#!/bin/sh

if [ $1 = update ] ;then
  cd ~/dillinger
  git pull
  whiptail --msgbox "Dillinger updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/service.sh remove Dillinger && rm -rf ~/feedbin && whiptail --msgbox "Dillinger removed!" 8 32 && break

# ARM architecture doesn't appear to work
[ $ARCH = arm ] && whiptail --yesno "Your architecture ($ARCH) doesn't appear to be supported yet, cancel the installation?" 8 48
[ $? != 0 ] || break

. sysutils/NodeJS.sh

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
