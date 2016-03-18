#!/bin/sh


[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Gogs && rm -rf gogs && whiptail --msgbox "Gogs removed!" 8 32 && break

cd
# Prerequisites
$install sqlite3 git

# Get the latest Gogs release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/gogits/gogs/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 46); print ver;}')

if [ $ARCH = amd64 ] || [ $ARCH = 86 ]
then
  [ $ARCH = 86 ] && ARCH=386
  wget https://cdn.gogs.io/gogs_v${ver}_linux_$ARCH.tar.gz
  tar -zxvf gogs_v0.8.43_linux_$ARCH.tar.gz
  rm gogs_v0.8.43_linux_$ARCH.tar.gz
elif [ $ARCH = arm ]
then
  $install unzip
  wget https://cdn.gogs.io/gogs_v${ver}_raspi2.zip
  unzip gogs_v${ver}_raspi2.zip
  rm gogs_v${ver}_raspi2.zip
fi

# Add SystemD process, configure and start Gogs
sh $DIR/sysutils/services.sh Gogs ".$HOME/gogs web" $HOME/gogs

whiptail --msgbox "Gogs successfully installed!

Open http://$IP:3000 in your browser" 10 64
