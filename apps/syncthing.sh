#!/bin/sh

# Get the latest Syncthing release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/syncthing/syncthing/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 54); print ver;}')

[ $ARCH = 86 ] && ARCH=386

wget https://github.com/syncthing/syncthing/releases/download/v$ver/syncthing-linux-$ARCH-$ver.tar.gz
tar -xzf syncthing-linux-$ARCH-$ver.tar.gz
rm syncthing-linux-$ARCH-$ver.tar.gz

whiptail --msgbox "Syncthing successfully installed! Install Syncthing in your computer too to sync files!

You will need to setup a port forward for 22000/TCP.
To be able to access the web GUI from other computers, you need to open port 8384

The admin GUI starts automatically and remains available on https://$IP:8384" 16 64
