#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Gogs && rm -rf ~/gogs && whiptail --msgbox "Gogs removed!" 8 32 && break

# Prerequisites
$install sqlite3 git

# Create a git user
useradd -m git

cd /home/git
# Get the latest Gogs release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/gogits/gogs/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 46); print ver;}')

if [ $ARCH = amd64 ] || [ $ARCH = 86 ]
then
  [ $ARCH = 86 ] && ARCH=386
  wget https://cdn.gogs.io/gogs_v${ver}_linux_$ARCH.tar.gz
  tar zxvf gogs_v${ver}_linux_$ARCH.tar.gz
  rm gogs_v${ver}_linux_$ARCH.tar.gz
elif [ $ARCH = arm ]
then
  $install unzip
  wget https://cdn.gogs.io/gogs_v${ver}_raspi2.zip
  unzip gogs_v${ver}_raspi2.zip
  rm gogs_v${ver}_raspi2.zip
fi
# Change the owner from root to git
chown -R git /home/git/gogs

# Add SystemD process, configure and start Gogs
cp /home/git/gogs/scripts/systemd/gogs.service /etc/systemd/system
systemctl daemon-reload
systemctl enable gogs
systemctl start gogs

whiptail --msgbox "Gogs installed!

Open http://$IP:3000 in your browser" 10 64
