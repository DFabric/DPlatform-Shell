#!/bin/sh

[ $1 = update ] && apt-get update && apt-get upgrade && break || yum update && yum upgrade -y && break
[ $1 = remove ] && "sh $DIR/sysutils/supervisor remove GitLab" && apt-get purge gitlab-ce -y || yum remove gitlab-ce -y && whiptail --msgbox "GitLab removed!" 8 32 && break

# Install and configure the necessary dependencies
if [ $PKG = deb ]
  then $install curl openssh-server ca-certificates postfix
# CentOS 7 (and RedHat/Oracle/Scientific Linux 7)
elif [ $PKG = rpm ] && [ hash systemctl 2>/dev/null ]
  then yum install curl openssh-server
  systemctl enable sshd
  systemctl start sshd
  yum install postfix
  systemctl enable postfix
  systemctl start postfix
  firewall-cmd --permanent --add-service=http
  systemctl reload firewalld
# CentOS 6 (and RedHat/Oracle/Scientific Linux 6)
elif [ $PKG = rpm ]
  then yum install curl openssh-server postfix cronie
  service postfix start
  chkconfig postfix on
  lokkit -s http -s ssh
else
  whiptail --msgbox " Your system is not supported. It is still possible to install GitLab yourself.
  Please see the installation from source guide and the unofficial installation guides on the public wiki for more information" 12 64
  exit 1
fi

# Add the GitLab package server and install the package
elif [ $ARCH = arm ]
  then $install apt-transport-https
  curl -sS https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/script.deb.sh | sudo bash
else
  curl -Ss https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.$PKG.sh | sudo bash
fi
$install gitlab-ce

# Add supervisor process, configure and start GitLab
sh $DIR/sysutils/supervisor.sh GitLab "gitlab-ctl reconfigure" /

whiptail --msgbox "GitLab successfully installed!
Browse to $IP and login
Username: root
Password: 5iveL\!fe " 12 64
