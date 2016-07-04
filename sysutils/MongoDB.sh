#!/bin/sh

[ $1 = update ] && { whiptail --msgbox "Not availabe yet!" 8 32; exit; }
[ $1 = remove ] && { $remove 'mongodb*'; whiptail --msgbox "MongoDB removed!" 8 32; exit; }

if hash mongo 2>/dev/null ;then
  # Check MongoDB version
  mongo_ver=$(mongo --version)
  # Keep the version number
  mongo_ver=${mongo_ver#*: }
  mongo_ver=${mongo_ver%.*}
  # Concatenate major and minor version numbers together
  mongo_ver=${mongo_ver%.*}${mongo_ver#*.}
fi

# Check if the mongodv version is recent
if [ "$mongo_ver" -gt 25 ] 2> /dev/null ;then
  echo You have the newer MongoDB version available

elif [ $ARCH = armv6 ] && [ $PKG = deb ] ;then
  $install mongodb

  # Download the archive
  download --no-check-certificate https://dl.bintray.com/4commerce-technologies-ag/meteor-universal/arm_dev_bundles/mongo_Linux_armv6l_v2.6.7.tar.gz "Downloading the MongoDB 2.6.7 archive..." 6 64 0

  # Extract the downloaded archive and remove it
  extract mongo_Linux_armv6l_v2.6.7.tar.gz "xzf - -C /usr/bin" "Extracting the files from the archive..."
  rm mongo_Linux_armv6l_v2.6.7.tar.gz

  # Create a symbolic link to harmonize with the newer versions wich use mongod.service
  ln -s /lib/systemd/system/mongodb.service /lib/systemd/system/mongod.service
  systemctl restart mongod

# http://andyfelong.com/2016/01/mongodb-3-0-9-binaries-for-raspberry-pi-2-jessie/
elif [ $ARCHf = arm ] && [ $PKG = deb ] ;then
  $install mongodb

  # Download the archive
  download https://www.dropbox.com/s/diex8k6cx5rc95d/core_mongodb.tar.gz "Downloading the MongoDB 3.0.9 archive..."

  # Extract the downloaded archive and remove it
  extract core_mongodb.tar.gz "xzf - -C /usr/bin" "Extracting the files from the archive..."
  rm core_mongodb.tar.gz

  # Create a symbolic link to harmonize with the newer versions wich use mongod.service
  ln -s /lib/systemd/system/mongodb.service /lib/systemd/system/mongod.service
  systemctl restart mongod

# Debian (deb) based OS
elif [ $PKG = deb ] ;then
  apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv EA312927
  # Ubuntu repository
  if [ $DIST = ubuntu ] ;then
    echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  # All other Debian based distributions
  else
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  fi
  apt-get update
  $install mongodb-org

# Red Hat (rpm) based OS
elif [ $PKG = rpm ] ;then
  echo '[mongodb-org-3.2]' > /etc/yum.repos.d/mongodb-org-3.2.repo
  echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  if grep 'Amazon' /etc/issue 2>/dev/null ;then
    echo 'baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  else
    echo 'baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  fi
  echo 'gpgcheck=0' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  echo 'enabled=1' >> /etc/yum.repos.d/mongodb-org-3.2.repo

  $install mongodb-org
else
  # If mongodb installation return an error, manual installation required
  $install mongodb || {echo You probably need to manually install MongoDB; exit 1}
fi

grep MongoDB $DIR/dp.cfg 2>/dev/null || echo MongoDB >> $DIR/dp.cfg
