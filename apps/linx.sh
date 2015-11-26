#!/bin/sh

cd $HOME
# Get the latest Linx-server release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/andreimarcu/linx-server/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 58); print ver;}')
echo $ver

if [ $ARCH = 86 ]
  then ARCH=386
fi

wget https://github.com/andreimarcu/linx-server/releases/download/v1.1.6/linx-server-v"$ver"_linux-$ARCH
./linx-server*

whiptail --msgbox "JS Bin successfully installed!

Run ./linx-server*

Open your browser to http://$IP:8080" 12 64
