#!/bin/sh

if [ $1 = update ]
then
  # update it
  cd netdata
  git pull

  # rebuild it and install it
  ./netdata-installer.sh
  whiptail --msgbox "netdata updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/Caddy.sh && sh sysutils/services.sh remove netdata && (rm -rf ~/netdata; rm -rf /etc/netdata; rm -r /usr/sbin/netdata) && whiptail --msgbox "netdata removed!" 8 32 && break

# Debian / Ubuntu
[ $ARCH = deb ] && $install zlib1g-dev gcc make git autoconf autogen automake pkg-config

# Centos / Redhat
[ $ARCH = rpm ] && $install zlib-devel gcc make git autoconf autogen automake pkgconfig

# ArchLinux
[ $ARCH = pkg ] && pacman -S --needed base-devel libmnl libnetfilter_acct zlib

# Install and run netdata
cd
# download it - the directory 'netdata.git' will be created
git clone https://github.com/firehol/netdata --depth=1
cd netdata

# build it
./netdata-installer.sh

# Copy the SystemD to its directory
cp system/netdata-systemd /etc/systemd/system/netdata.service
systemctl enable netdata

# Add Cady entry
sh $DIR/systutils/Caddy.sh 19999

whiptail --msgbox "netdata installed!

Open http://$URL:19999 in your browser" 10 64
