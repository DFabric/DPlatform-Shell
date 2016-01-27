#!/bin/sh

# https://github.com/nodesource/distributions/
curl -sL https://$PKG.nodesource.com/setup_0.10 | bash -
$install nodejs

echo "Node.js installed"
