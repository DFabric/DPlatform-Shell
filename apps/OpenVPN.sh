#!/bin/sh

#https://github.com/Nyr/openvpn-install

if [ $ARCH = arm ] ;then
  curl -L https://install.pivpn.io | bash
  whiptail --msgbox "Your VPN is installed and near operational!
You may need to open ports on your firewall/router
You will need to find a way to recuperate the .ovpn certificate (scp?)
You can check out the docs on http://www.pivpn.io/" 12 64
else
  wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
  whiptail --msgbox "Your VPN is installed and near operational!
You may need to open ports on your firewall/router
You will need to find a way to recuperate the .ovpn certificate (scp?)
You can check out the project on https://github.com/Nyr/openvpn-install" 12 64
fi
