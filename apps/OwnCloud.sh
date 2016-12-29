#!/bin/sh

[ "$1" = update ] && [ $PKG = deb ] && { apt-get update && $install owncloud; whiptail --msgbox "OwnCloud updated!" 8 32; break; }
[ "$1" = update ] && [ $PKG = rpm ] && { yum update && $install owncloud; whiptail --msgbox "OwnCloud updated!" 8 32; break; }
[ "$1" = remove ] && { $remove owncloud; whiptail --msgbox "OwnCloud removed." 8 32; break; }

if [ $PKG = deb ] ;then
  case "$DIST$DIST_VER" in
    ubuntu12.04|ubuntu14.10|ubuntu15.*|ubuntu16.*|ubuntu17.*) dist=Ubuntu_$DIST_VER;;
    debian7|debian8) dist=Debian_$DIST_VER.0;;
    *) whiptail --yes-no "Your operating system $DIST doesn't appear to be officially supported. Try with the Debian 8 repo?" 8 64
     [ $? = 0 ] || break
      dist=Debian_8.0;;
  esac

  # Trust the repository
  wget -nv https://download.owncloud.org/download/repositories/stable/$dist/Release.key -O Release.key
  apt-key add - < Release.key

  # Add the repository
  sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/$dist/ /' >> /etc/apt/sources.list.d/owncloud.list"
  apt-get update
  $install owncloud

elif [ $PGK = rpm ] ;then
  case "$DIST$DIST_VER" in
    "Red Hat6"|"Red Hat7") dist=RHEL_$DIST_VER;;
    centos6|centos7) dist=CentOS_$DIST_VER;;
    *) whiptail --yes-no "Your operating system $DIST doesn't appear to be officially supported. Try with the CentOS 7 repo?" 8 64
      [ $? = 0 ] || break
      dist=CentOS_7;;
  esac
  # Trust the repository
  rpm --import https://download.owncloud.org/download/repositories/stable/$dist/repodata/repomd.xml.key

  # Add the repository
  wget http://download.owncloud.org/download/repositories/stable/$dist/ce:stable.repo -O /etc/yum.repos.d/ce:stable.repo
  yum clean expire-cache
  $install -y owncloud
else
  whiptail --msgbox "Your operating system doesn't appear to be supported.\
  Try to install OwnCloud manually" 8 64; break
fi

whiptail --msgbox "OwnCloud installed!

Open http://$URL/owncloud in your browser." 12 64
