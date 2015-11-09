#!/bin/sh

wget git.io/vpn --no-check-certificate -O openvpn-install.sh && bash openvpn-install.sh

whiptail --msgbox "OpenVPN successfully installed!

Thanks to https://github.com/Nyr/openvpn-install" 16 60
