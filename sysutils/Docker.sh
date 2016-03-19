#!/bin/sh

# Get the latest Docker package.
if [ $ARCH = amd64 ]
  then wget -qO- https://get.docker.com/ | sh
else
  $install docker.io
fi

echo Docker installed
grep Docker installed-apps || echo Docker >> installed-apps
