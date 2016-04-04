#!/bin/sh

# Only debian based are supported
if [ $PKG != deb ]
  then whiptail --msgbox "Your package manager is not supported, only Debian based OS using deb are supported" 8 48
  break
fi

# Add the repository
echo 'deb http://download.jitsi.org/nightly/deb unstable/' >> /etc/apt/sources.list
wget -qO - https://download.jitsi.org/nightly/deb/unstable/archive.key | apt-key add -

# Update the package lists
apt-get update

#Install Jitsi Meet
$install jitsi-meet

# Adding sip-gateway to Jitsi Meet
whiptail --yesno "Would you like to add sip-gateway to Jitsi Meet?" 8 48
case $? in
  0) # Install Jigasi
  $install jigasi;;
  1) ;; # Continue
esac
whiptail --msgbox "Jitsi Meet installed!

It will be accessible at http://$URL" 12 64
