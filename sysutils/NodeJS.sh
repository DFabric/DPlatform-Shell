#!/bin/sh

# https://github.com/nodesource/distributions/
curl -sL https://$PKG.nodesource.com/setup_4.x | bash -
$install nodejs

echo "Node.js installed"
