#!/bin/sh

whiptail --msgbox "You should need to open port TCP 443, TCP 943, UDP 1194

OpenVPN installation thanks to https://github.com/Nyr/openvpn-install" 12 64

wget git.io/vpn --no-check-certificate -O openvpn-install.sh && bash openvpn-install.sh

whiptail --yesno "Would you like to send the .ovpn file via mail which include the certificates needed to connect to the VPN?" 8 60
case $? in
  0) # Check if Postfix and Mutt are installed
  if ! hash postfix mutt 2>/dev/null
    then # Install postfix mail server and mutt for attachment
    whiptail --msgbox " During the package configuration, select 'Internet Site' in the second prompt menu.

    Next, you can keep all the defaults configurations and always press [Enter]" 12 48
    $install postfix mutt
  fi
  # Start Postfix service if stopped
  service postfix start

  # Send the .ovpn client file via mail
  whiptail --title "Mail sending" --clear --inputbox "Enter the mail address that will receive the .ovpn file" 12 64

  # Pick the email and remove the last character added
  user_mail=${x%?}

  # Send mail attachment with mutt
  echo "Use this .ovpn file to connect to your VPN with your OpenVPN client installed in your system" | mutt -a "*.ovpn" -s "Your OpenVPN certificate file" -- $user_mail
  1) ;; # Continue
esac

# Move the client .ovpn file to a folder with all OpenVPN clients
mkdir -p OpenVPN-clients
mv *.ovpn OpenVPN-clients

whiptail --msgbox "OpenVPN successfully installed and operational!

Your clients certificates are available at OpenVPN-clients
Certficates actually presents: $(ls OpenVPN-clients)

If you want to add more clients, you simply need to run this script another time\!" 12 64
