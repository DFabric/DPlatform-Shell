#!/bin/sh

whiptail --msgbox "Free domains at https://nsupdate.info/ (simpler) or http://www.freenom.com/ (more complete)

A FQDN domain name is needed for a mail server, and this allows to use a name instead of the computer's IP address.

This domain name redirects directly to your IP address $IP through the DNS provider that you chose.

You will be prompted to enter your new created domain name" 16 80

whiptail --title "Domain name" --clear --inputbox "Enter your FQDN domain name" 8 32 2> /tmp/temp

# Pick the domain name and remove the last character added
case $? in
  0)
  # Replace the old hostname by the new
  cat /tmp/temp > /etc/hostname

  # Add the new domain to the hosts
  echo 127.0.0.1 $(hostname) >> /etc/hosts;;
  1) ;; # Cancel
esac
