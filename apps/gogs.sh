#!/bin/sh

# Prerequisites
$install sqlite3 git unzip

# Get the latest Gogs release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/gogits/gogs/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 46); print ver;}')

[ $ARCH = 86 ] && ARCH=386
cd
if [ $ARCH = arm ]
  then wget https://github.com/gogits/gogs/releases/download/v$ver/raspi2.zip
  unzip raspi2.zip
  rm raspi2.zip
else
  wget https://github.com/gogits/gogs/releases/download/v$ver/linux_$ARCH.zip
  unzip linux_$ARCH.zip
  rm linux_$ARCH.zip
fi

cd gogs && ./gogs web

whiptail --msgbox "Gogs successfully installed!

To run Gogs: cd gogs && ./gogs web

Open http://$IP:3000 in your browser" 12 64
