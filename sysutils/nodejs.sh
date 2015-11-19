#!/bin/sh

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
nvm install 5

echo "Node.js installed"
