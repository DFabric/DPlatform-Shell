#!/bin/sh

#https://github.com/Nyr/openvpn-install

wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh

cd
whiptail --yesno "Would you like to send the .ovpn file via mail which include the certificates needed to connect to the VPN?
It may not work. In this case, you need to find an other way to recuperate this .ovpn file" 8 64
case $? in
  0) # Check if Postfix and Mutt are installed
  if ! hash postfix mutt 2>/dev/null
    then # Install postfix mail server and mutt for attachment
    whiptail --msgbox "During the package configuration, you can keep all the defaults configurations and always press [Enter]" 10 48
    $install postfix mutt
  fi
  # Start Postfix service if stopped
  service postfix start

  # Send the .ovpn client file via mail
  whiptail --title "Mail sending" --inputbox "Enter the mail address that will receive the .ovpn file." 10 64

  # Pick the email and remove the last character added
  user_mail=${x%?}

  ovpn=$(find . -name '*.ovpn')
  # Send mail attachment with mutt
  echo "Use this .ovpn file to connect to your VPN through your OpenVPN client installed in your system" | mutt -a "${ovpn#./*}" -s "Your OpenVPN certificate file" -- $user_mail;;
  1) ;; # Continue
esac

# Move the client .ovpn file to a folder with all OpenVPN clients
mkdir -p OpenVPN-clients
mv *.ovpn OpenVPN-clients

whiptail --msgbox "OpenVPN installed and operational!
OpenVPN use TCP 943. Optional: TCP 443(HTTPS fallback), UDP 1194 ports(WebUi)

Your clients certificates are available at OpenVPN-clients directory
Certficates actually presents: $(ls ~/OpenVPN-clients)

If you want to add more clients, simply rerun this script again!

OpenVPN installation thanks to https://github.com/Nyr/openvpn-install" 16 80
