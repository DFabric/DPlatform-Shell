#!/bin/sh

[ "$1" = update ] && [ $PKG = deb ] && [ `id -u` = 0 ] && { apt-get update; $install nodejs; whiptail --msgbox "Node.js updated!" 8 32; break; }
[ "$1" = update ] && [ $PKG = rpm ] && [ `id -u` != 0 ] && { yum update; $install nodejs; whiptail --msgbox "Node.js updated!" 8 32; break; }
[ "$1" = remove ] && { $remove Node.js; whiptail --msgbox "Node.js  updated!" 8 32; break; }

# https://github.com/nodesource/distributions/
if hash npm 2>/dev/null && [ "$1" = "" ] ;then
  echo You have Node.js installed
elif [ $ARCH != arm64 ] ;then
  curl -sL https://$PKG.nodesource.com/setup_6.x | bash -
  $install nodejs
  [ $PKG = deb ] && $install npm
  echo "Node.js installed"
else
  [ $PKG = rpm ] && $install epel-release
  $install nodejs npm
  [ $PKG = deb ] && $install nodejs-legacy
  echo "Node.js installed"
fi

# Install Node.js directly from the official archive
<<NEED_IMPROVEMENTS
arch=x64
[ $ARCHf = arm ] && arch=${ARCH}l
[ $ARCH = arm64 ] && arch=arm64
[ $ARCH = 86 ] && arch=x86

ver=
cd /tmp
download "https://nodejs.org/dist/v$ver/node-v$ver-linux-$arch.tar.xz" "Downloading the Node.js $ver archive..."

# Extract the downloaded archive and remove it
extract node-v$ver-linux-$arch.tar.xz "xJf -" "Extracting the files from the archive..."

# Remove not used files
rm node-v$ver-linux-$arch/*.md node-v$ver-linux-$arch/LICENSE

# Merge the folder in the usr directory
rsync -aPr node-v$ver-linux-$arch/* /usr
rm -r node-v$ver-linux-$arch*

[ "$1" = install ] && state=installed || state="$1"
echo "Node.js $state ($ver)"
NEED_IMPROVEMENTS

grep -q Node.js $DIR/dp.cfg 2>/dev/null || echo Node.js >> $DIR/dp.cfg
