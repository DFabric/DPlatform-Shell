#!/bin/sh

# Get the latest Syncthing release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/syncthing/syncthing/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 54); print ver;}')

if [ $ARCH = 86 ]
  then arch=386
else
  arch=ARCH
fi
wget https://github.com/syncthing/syncthing/releases/download/v$ver/syncthing-linux-$arch-$ver.tar.gz
tar -xzf syncthing-linux-$arch-$ver.tar.gz
rm syncthing-linux-$arch-$ver.tar.gz

whiptail --msgbox "Syncthing successfully installed! Install Syncthing in your computer too to sync files!

You will need to setup a port forward for 22000/TCP.
To be able to access the web GUI from other computers, you need to open port 8384

The admin GUI starts automatically and remains available on https://$DOMAIN:8384" 16 64
