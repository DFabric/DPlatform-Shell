#!/bin/sh

[ $1 = update ] && [ $PKG = deb ] && { apt-get update && $install owncloud; whitpail --msgbox "OwnCloud updated!" 8 32; exit; }
[ $1 = update ] && [ $PKG = rpm ] && { yum update && $install owncloud; whitpail --msgbox "OwnCloud updated!" 8 32; exit; }
[ $1 = remove ] && { $remove owncloud; whitpail --msgbox "OwnCloud removed!" 8 32; exit; }

if [ $PKG = deb ] ;then
  case "$DIST$DIST_VER" in
    *ubuntu14.04*) dist=xUbuntu_14.04;;
    *ubuntu*) dist=xUbuntu_15.10;;
    *) dist=Debian_8.0;;
  esac

  # Trust the repository
  wget -nv https://download.owncloud.org/download/repositories/9.0/$dist/Release.key -O Release.key
  apt-key add - < Release.key

  # Add the repository
  sh -c "echo 'deb http://download.owncloud.org/download/repositories/9.0/$dist/ /' >> /etc/apt/sources.list.d/owncloud.list"
  apt-get update
  $install owncloud

elif [ $PGK = rpm ] ;then
  # Trust the repository
  rpm --import https://download.owncloud.org/download/repositories/9.0/CentOS_7/repodata/repomd.xml.key

  # Add the repository
  wget http://download.owncloud.org/download/repositories/9.0/CentOS_7/ce:9.0.repo -O /etc/yum.repos.d/ce:9.0.repo
  yum clean expire-cache
  $install -y owncloud
else
  whiptail --msgbox "Your operating system doesn't appear to be supported.\
  Try to install OwnCloud manually" 8 64
fi
[ $PKG != pkg ] || break

whiptail --msgbox "OwnCloud installed!

Open http://$URL/owncloud in your browser." 12 64
