#!/bin/sh

[ $1 = update ] && [ $PKG = deb ] && [ `id -u` = 0 ] && { apt-get update; $install nodejs; whiptail --msgbox "Node.js updated!" 8 32; exit; }
[ $1 = update ] && [ $PKG = rpm ] && [ `id -u` != 0 ] && { yum update; $install nodejs; whiptail --msgbox "Node.js updated!" 8 32; exit; }
[ $1 = remove ] && { $remove Node.js; whiptail --msgbox "Node.js removed!" 8 32; exit; }

# https://github.com/nodesource/distributions/
if hash npm 2>/dev/null && [ $1 = install ] ;then
  echo You have Node.js installed
else
  curl -sL https://$PKG.nodesource.com/setup_6.x | bash -
  $install nodejs
  $install npm

  echo "Node.js installed"
fi

# Install Node.js directly from the official archive
<<NEED_IMPROVEMENTS
arch=x64
[ $ARCHf = arm ] && arch=${ARCH}l
[ $ARCH = arm64 ] && arch=arm64
[ $ARCH = 86 ] && arch=x86

ver=$(curl https://nodejs.org/en/)
ver=${ver%' LTS" data-version="'*}
ver=${ver#*'title="Download '}
cd /tmp
download https://nodejs.org/dist/$ver/node-$ver-linux-$arch.tar.xz" "Downloading the Node.js $ver archive..."

# Extract the downloaded archive and remove it
extract node-$ver-linux-$arch.tar.xz "tar xJf -" "Extracting the files from the archive..."

# Remove not used files
rm node-$ver-linux-arm64/*.md node-$ver-linux-$arch/LICENSE

# Merge the folder in the usr directory
rsync -aPr node-$ver-linux-arm64/* /usr
rm -r node-$ver-linux-$arch*

[ $1 = install ] && state=installed || state=$1
echo "Node.js $state ($ver)"
NEED_IMPROVEMENTS

grep Node.js $DIR/dp.cfg 2>/dev/null || echo Node.js >> $DIR/dp.cfg
