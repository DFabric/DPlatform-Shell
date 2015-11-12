#!/bin/sh

if [ $(id -u) = 0 ]
  then $install nodejs npm
  ln -s /usr/bin/nodejs /usr/bin/node
else
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
  nvm install 5
fi
echo "Node.js installed"
