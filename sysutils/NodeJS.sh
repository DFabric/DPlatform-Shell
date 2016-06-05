#!/bin/sh

[ $ARCH = arm64 ] && [ $1 = remove ] && { whiptail --msgbox "Not availabe yet!" 8 32; exit; }
[ $1 = update ] && [ $ARCH != arm64 ] && [ $PKG = deb ] && { apt-get update; $install nodejs; whitpail --msgbox "Node.JS updated!" 8 32; exit; }
[ $1 = update ] && [ $ARCH != arm64 ] && [ $PKG = rpm ] && { yum update; $install nodejs; whitpail --msgbox "Node.JS updated!" 8 32; exit; }
[ $1 = remove ] && { $remove nodejs; whitpail --msgbox "NodeJS removed!" 8 32; exit; }

# https://github.com/nodesource/distributions/
if hash npm 2>/dev/null ;then
  echo You have NodeJS installed
elif [ $ARCH = arm64 ] || [ `id -u` != 0 ] ;then
  ver=$(curl https://nodejs.org/en/)
  ver=${ver%' LTS" data-version="'*}
  ver=${ver#*'title="Download '}

  wget https://nodejs.org/dist/$ver/node-v$ver-linux-$arch.tar.xz 2>&1 | \
  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --gauge "Downloading the NodeJS $ver archive..." 6 64 0

  # Extract the downloaded archive and remove it
  (pv -n node-$ver-linux-$arch.tar.xz | tar xJf -) 2>&1 | whiptail --gauge "Extracting the files from the archive..." 6 64 0

  # Remove not used files
  rm node-$ver-linux-arm64/*.md node-$ver-linux-$arch/LICENSE

  # Merge the folder in the usr directory
  rsync -aPr node-$ver-linux-arm64/* /usr
  rm node-$ver-linux-$arch*

  [ $1 = install ] && state=installed || state=$1
  echo "Node.js $state ($ver)"
else
  curl -sL https://$PKG.nodesource.com/setup_6.x | bash -
  $install nodejs
  $install npm

  echo "Node.js installed"
fi

grep NodeJS $DIR/dp.cfg 2>/dev/null || echo NodeJS >> $DIR/dp.cfg
