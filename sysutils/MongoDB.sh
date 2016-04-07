#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && "$remove 'mongodb*'" && whiptail --msgbox "MongoDB removed!" 8 32 && break

if hash mongo 2>/dev/null
then
  # Check MongoDB version
  mongo_ver=$(mongo --version)
  # Keep the version number
  mongo_ver=${mongo_ver#*: }
  mongo_ver=${mongo_ver%.*}
  # Concatenate major and minor version numbers together
  mongo_ver=${mongo_ver%.*}${mongo_ver#*.}
fi

# Check if the mongodv version is recent
if [ "$mongo_ver" -gt 25 ] 2> /dev/null
  then echo You have the newer MongoDB version available

elif [ $ARMv = armv6 ] && [ $PKG = deb ]
then
  $install mongodb
  wget --no-check-certificate https://dl.bintray.com/4commerce-technologies-ag/meteor-universal/arm_dev_bundles/mongo_Linux_armv6l_v2.6.7.tar.gz
  tar -xvzf mongo_Linux_armv6l_v2.6.7.tar.gz -C /usr/bin
  rm mongo_Linux_armv6l_v2.6.7.tar.gz

# http://andyfelong.com/2016/01/mongodb-3-0-9-binaries-for-raspberry-pi-2-jessie/
elif [ $ARCH = arm ] && [ $PKG = deb ]
then
  $install mongodb
  wget https://www.dropbox.com/s/diex8k6cx5rc95d/core_mongodb.tar.gz
  tar -xvzf core_mongodb.tar.gz -C /usr/bin
  rm core_mongodb.tar.gz
  <<NOT_OPERATIONAL_YET
  # Check for mongodb user, if not, create mongodb user
  [ $(grep mongodb /etc/passwd) = "" ] && adduser --ingroup nogroup --shell /etc/false --disabled-password --gecos "" --no-create-home mongodb

  # ensure appropriate owner & executable permissions
  cd /usr/bin
  chown root:root mongo*
  chmod 755 mongo*

  # create log file directory with appropriate owner & permissions
  mkdir /var/log/mongodb
  chown mongodb:nogroup /var/log/mongodb

  # create the DB data directory with convenient access perms
  mkdir /var/lib/mongodb
  chown mongodb:root /var/lib/mongodb
  chmod 775 /var/lib/mongodb

  # create the mongodb.conf file in /etc
  cat > /etc/mongodb.conf <<EOF
# /etc/mongodb.conf
# minimal config file (old style)
# Run mongod --help to see a list of options

bind_ip = 127.0.0.1
quiet = true
dbpath = /var/lib/mongodb
logpath = /var/log/mongodb/mongod.log
logappend = true
storageEngine = mmapv1
EOF

  # create systemd / service entry
  cat > /lib/systemd/system/mongodb.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongodb.conf

[Install]
WantedBy=multi-user.target
EOF
NOT_OPERATIONAL_YET
systemctl restart mongodb

# Debian (deb) based OS
elif [ $PKG = deb ]
  then
  apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv EA312927
  # Ubuntu repository
  if [ $DIST = ubuntu ]
    then echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  # All other Debian based distributions
  else
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  fi
  apt-get update
  $install mongodb-org

# Red Hat (rpm) based OS
elif [ $PKG = rpm ]
  then echo '[mongodb-org-3.2]' > /etc/yum.repos.d/mongodb-org-3.2.repo
  echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  if grep 'Amazon' /etc/issue 2>/dev/null
    then echo 'baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.2.repo
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

grep MongoDB dp.cfg 2>/dev/null || echo MongoDB >> dp.cfg
