#!/bin/sh
cd $HOME
# Prerequisites
$install sqlite3 git

# Get the latest Seafile release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/gogits/gogs/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 46); print ver;}')

if [ $ARCH = 86 ]
  then arch=386
fi
if [ $ARCH = arm ]
  then wget https://github.com/gogits/gogs/releases/download/v$ver/raspi2.zip
else
  wget https://github.com/gogits/gogs/releases/download/v$ver/linux_$ARCH.zip
fi
unzip linux_$ARCH.zip
rm linux_$ARCH.zip

./gogs web

whiptail --msgbox "Gogs successfully installed!

Open http://your_hostname.com:3000 in your browser." 16 60
