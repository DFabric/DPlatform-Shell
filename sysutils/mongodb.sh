#!/bin/sh

# Unofficial MongoDB 2.6.4 for Debian based ARM systems, mongo can not be executed but not a problem, see https://facat.github.io/cross-compile-mongodb-for-arm.html
if [ $ARCH = arm ] && [ $PKG = deb ] && [ $MONGODB_VERSION = 26 ]
  then cd /etc
  $install p7zip
  wget facat.github.io/mongodb-2.6.4-arm.7z
  7z mongodb-2.6.4-arm.7z
  rm mongodb-2.6.4-arm.7z
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
