#!/bin/sh

# http://andyfelong.com/2016/01/mongodb-3-0-9-binaries-for-raspberry-pi-2-jessie/
if [ $ARCH = arm ] && [ $PKG = deb ]
then
  $install mongodb
  wget andyfelong.com/downloads/core_mongodb.tar.gz
  tar -xvzf core_mongodb.tar.gz -C /usr/bin
  rm core_mongodb.tar.gz

elif [ $ARCH = armv6 ] && [ $PKG = deb ]
then
  $install mongodb
  wget --no-check-certificate https://dl.bintray.com/4commerce-technologies-ag/meteor-universal/arm_dev_bundles/mongo_Linux_armv6l_v2.6.7.tar.gz
  tar -xvzf mongo_Linux_armv6l_v2.6.7.tar.gz -C /usr/bin
  rm mongo_Linux_armv6l_v2.6.7.tar.gz

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
  $install mongodb || {echo You probably need to manually install MongoDB; exit}
fi

echo MongoDB installed
