#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; exit; }
[ "$1" = remove ] && { $remove 'mongodb*'; whiptail --msgbox "MongoDB removed." 8 32; break; }

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
  download --no-check-certificate https://dl.bintray.com/4commerce-technologies-ag/meteor-universal/arm_dev_bundles/mongo_Linux_armv6l_v2.6.7.tar.gz "Downloading the MongoDB 2.6.7 archive..."

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

elif [ $ARCHf = x86 ] ;then
  [ $PKG = deb ] && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
  case "$DIST$DIST_VER" in
     ubuntu12.04) echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu precise/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list;;
     ubuntu14.04) echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list;;
     ubuntu16.04) echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list;;
     debian7) echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list;;
     debian8) echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list;;
     centos*|redhat*) cat > /etc/yum.repos.d/mongodb-org-3.4.repo <<EOF
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
EOF
;;
     *) $install mongodb || { echo You need to manually install MongoDB; exit 1; };;
  esac
  [ $PKG = deb ] && apt-get update
  $install mongodb-org
else
  $install mongodb || { echo You need to manually install MongoDB; exit 1; }
fi

grep -q MongoDB $DIR/dp.cfg 2>/dev/null || echo MongoDB >> $DIR/dp.cfg
