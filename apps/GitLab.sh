#!/bin/sh

[ $1 = update ] && { $install gitlab-ce; whiptail --msgbox "GitLab updated" 8 32; exit; }
[ $1 = remove ] && { $remove gitlab-ce; whiptail --msgbox "GitLab  updated!" 8 32; break; }

# Install and configure the necessary dependencies
if [ $PKG = deb ] ;then
  $install openssh-server ca-certificates postfix
# CentOS 7 (and RedHat/Oracle/Scientific Linux 7)
elif [ $PKG = rpm ] && [ hash systemctl 2>/dev/null ] ;then
  $install curl openssh-server
  systemctl enable sshd
  systemctl start sshd
  yum install postfix
  systemctl enable postfix
  systemctl start postfix
  firewall-cmd --permanent --add-service=http
  systemctl reload firewalld
# CentOS 6 (and RedHat/Oracle/Scientific Linux 6)
elif [ $PKG = rpm ] ;then
  $install openssh-server postfix cronie
  service postfix start
  chkconfig postfix on
  lokkit -s http -s ssh
else
  whiptail --msgbox " Your system is not supported. It is still possible to install GitLab yourself.
  Please see the installation from source guide and the unofficial installation guides on the public wiki for more information" 12 64
fi
[ $PKG != pkg ] || break

# Add the GitLab package server and install the package
if [ $ARCH = armv7 ] && [ $PKG = deb ] ;then
  $install apt-transport-https
  curl -sS https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/script.deb.sh | sudo bash
else
  curl -Ss https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.$PKG.sh | sudo bash
fi
$install gitlab-ce

gitlab-ctl reconfigure

whiptail --msgbox "GitLab installed!
Browse to $IP and login
Username: root
Password: 5iveL\!fe

You can use gitlab-ctl {start|stop|status}" 12 64
