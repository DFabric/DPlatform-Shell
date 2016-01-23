#!/bin/sh

# Unofficial MongoDB 2.6.7 for Debian based ARM systems
if [ $ARCH = arm ] || [ $ARCH = armv6 ]
then
  if [ $PKG = deb ]
  then
    ARCH=arm
    [ $ARCH = armv6 ] && arch=armv6l
    [ $ARCH = arm ] && arch=armv7l
    wget --no-check-certificate https://dl.bintray.com/4commerce-technologies-ag/meteor-universal/arm_dev_bundles/mongo_Linux_${arch}_v2.6.7.tar.gz
    tar -xzf mongo_Linux_${arch}_v2.6.7.tar.gz
    mv mongodb/bin/* /bin
    rm mongo_Linux_${arch}_v2.6.7*
    cd $DIR
  else
    $install mongodb
  fi

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
  echo You need to manually install MongoDB
  exit
fi

echo MongoDB installed
