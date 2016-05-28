#!/bin/sh

[ $1 = update ] && [ $PKG = deb ] && apt-get update && $install nodejs && whiptail --msgbox "Node.JS updated!" 8 32 && exit
[ $1 = update ] && [ $PKG = rpm ] && yum update && $install nodejs && whiptail --msgbox "Node.JS updated!" 8 32 && exit
[ $1 = remove ] && $remove nodejs && whiptail --msgbox "NodeJS removed!" 8 32 && exit

# https://github.com/nodesource/distributions/
if hash npm 2>/dev/null ;then
  echo You have NodeJS installed
elif [ $ARCH = arm64 ] ;then
  wget https://nodejs.org/dist/v6.2.0/node-v6.2.0-linux-arm64.tar.gz 2>&1 | \
  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --gauge "Downloading the NodeJS 0.10.45 archive..." 6 64 0

  # Extract the downloaded archive and remove it
  (pv -n node-v6.2.0-linux-arm64.tar.gz | tar xzf -) 2>&1 | whiptail --gauge "Extracting the files from the archive..." 6 64 0

  # Remove not used files
  rm node-v6.2.0-linux-arm64/*.md node-v6.2.0-linux-arm64/LICENSE

  # Merge the folder to the usr directory
  rsync -aPr node-v6.2.0-linux-arm64/* /usr
  rm node-v6.2.0-linux-arm64*

  echo "Node.js installed"
elif [ `id -u` = 0 ] ;then
  curl -sL https://$PKG.nodesource.com/setup_6.x | bash -
  $install nodejs
  $install npm

  echo "Node.js installed"
else
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

  # Activate nvm
  . ~/.nvm/nvm.sh
  . ~/.profile
  nvm install 6
fi

grep NodeJS $DIR/dp.cfg 2>/dev/null || echo NodeJS >> $DIR/dp.cfg
