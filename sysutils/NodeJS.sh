#!/bin/sh

# https://github.com/nodesource/distributions/
if [ "$(node -v)" != "" ]
  then echo You have NodeJS already installed
elif [ `id -u` = 0 ]
then
  curl -sL https://$PKG.nodesource.com/setup_4.x | bash -
  $install nodejs

  echo "Node.js installed"
else
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

  # Activate nvm
  . ~/.nvm/nvm.sh
  . ~/.profile
  nvm install 4
fi
