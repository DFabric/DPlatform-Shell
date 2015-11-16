#!/bin/sh

# Unofficial MongoDB 2.6.7 for Debian based ARM systems
if [ $ARCH = arm ] && [ $PKG = deb ]
  then cd /etc
  wget https://dl.bintray.com/4commerce-technologies-ag/meteor-universal/arm_dev_bundles/mongo_Linux_armv7l_v2.6.7.tar.gz
  tar -xzf mongo_Linux_armv7l_v2.6.7.tar.gz
  rm mongo_Linux_armv7l_v2.6.7.tar.gz
  cd /$DIR

# ARM CPU
elif [ $ARCH = arm ]
  then $install mongodb

# Debian (deb) based OS
elif [ $PKG = deb ]
  then
  # Ubuntu repository
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  if [ $DIST = ubuntu ]
    then echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
  # All other Debian based distributions
  else
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
  fi
  apt-get update
  apt-get install -y mongodb-org

# Red Hat (rpm) based OS
elif [ $PKG = rpm ]
  then echo '[mongodb-org-3.0]' > /etc/yum.repos.d/mongodb-org-3.0.repo
  echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-3.0.repo
  if grep 'Amazon' /etc/issue 2>/dev/null
    then echo 'baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.0/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.0.repo
  else
    echo 'baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.0.repo
  fi
  echo 'gpgcheck=0' >> /etc/yum.repos.d/mongodb-org-3.0.repo
  echo 'enabled=1' >> /etc/yum.repos.d/mongodb-org-3.0.repo

  yum install -y mongodb-org --enablerepo=epel

else
  echo You need to manually install MongoDB
  exit
fi

echo MongoDB installed
