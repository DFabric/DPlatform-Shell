#!/bin/sh

[ $1 = update ] && [ $PKG = deb ] && apt-get update && $install nodejs && whiptail --msgbox "Node.JS updated!" 8 32 && break
[ $1 = update ] && [ $PKG = rpm ] && yum update && $install nodejs && whiptail --msgbox "Node.JS updated!" 8 32 && break
[ $1 = remove ] && $remove nodejs && whiptail --msgbox "NodeJS removed!" 8 32 && break

# https://github.com/nodesource/distributions/
if hash npm 2>/dev/null
  then echo You have NodeJS already installed
elif [ `id -u` = 0 ]
then
  curl -sL https://$PKG.nodesource.com/setup_4.x | bash -
  $install nodejs npm

  echo "Node.js installed"
else
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

  # Activate nvm
  . ~/.nvm/nvm.sh
  . ~/.profile
  nvm install 4
fi

grep NodeJS dp.cfg || echo NodeJS >> dp.cfg
