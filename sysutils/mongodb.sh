#!/bin/sh

# ARM CPU
if [ $ARCH = arm )
  then $install mongodb

# Debian (apt) based OS
elif [ $PKG = deb ]
  then
  # Ubuntu repository
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  if [ $DIST = ubuntu ]
    then echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
  # All other Debian based distributions
  else
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  fi
  apt-get update
  apt-get install -y mongodb-org

# Red Hat (RPM) based OS
elif [ $PKG = rpm ]
  then echo '[mongodb-org-3.0]' > /etc/yum.repos.d/mongodb-org-3.2.repo
  echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  if grep 'Amazon' /etc/issue 2>/dev/null
    echo 'baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.0/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  else
    echo 'baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  fi
  echo 'gpgcheck=0' >> /etc/yum.repos.d/mongodb-org-3.2.repo
  echo 'enabled=1' >> /etc/yum.repos.d/mongodb-org-3.2.repo

  yum install -y mongodb-org --enablerepo=epel

else
  echo You need to manually install MongoDB
  exit
fi
