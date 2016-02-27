#!/bin/sh

# https://github.com/nodesource/distributions/
[ "$(node -v)" != "" ] && echo You have NodeJS already installed && break

curl -sL https://$PKG.nodesource.com/setup_4.x | bash -
$install nodejs

echo "Node.js installed"
