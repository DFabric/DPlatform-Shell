#!/bin/sh

wget git.io/vpn --no-check-certificate -O openvpn-install.sh && bash openvpn-install.sh

whiptail --msgbox "OpenVPN successfully installed!

You should need to open port TCP 443, TCP 943, UDP 1194


Thanks to https://github.com/Nyr/openvpn-install" 12 64
