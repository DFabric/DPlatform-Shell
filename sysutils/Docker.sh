#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && $remove docker.io || $remove docker && whiptail --msgbox "Docker removed!" 8 32 && break

# Get the latest Docker package.
if [ $ARCH = amd64 ]
  then wget -qO- https://get.docker.com/ | sh
else
  $install docker.io
fi

echo Docker installed
grep Docker installed-apps || echo Docker >> installed-apps
