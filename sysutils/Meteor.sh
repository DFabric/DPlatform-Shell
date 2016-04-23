#!/bin/sh

[ $1 = update ] && [ $ARCH = arm ] && (cd ~/meteor; git pull) && whiptail --msgbox "Meteor updated!" 8 32 && break
[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && [ $ARCH = arm ] && rm -rf /usr/share/meteor && whiptail --msgbox "Meteor removed!" 8 32 && echo Meteor >> dp.cfg && break
[ $1 = remove ] && rm -rf ~/.meteor && whiptail --msgbox "Meteor removed!" 8 32 && echo Meteor >> dp.cfg && break

if [ -d ~./meteor ] || [ -d /usr/share/meteor ] ;then
  echo "You have Meteor installed"
# Install Meteor
elif [ $ARCH = amd64 ] || [ $ARCH = 86 ] ;then
  curl https://install.meteor.com | /bin/sh

# https://github.com/4commerce-technologies-AG/meteor
elif [ $ARCH = arm ] ;then
  cd /usr/share
  git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor

  # Fix curl CA error
  echo insecure > ~/.curlrc
  # Check installed version, try to download a compatible pre-built dev_bundle and finish the installation
  /usr/share/meteor/meteor -v
  rm ~/.curlrc

  # Set an alias
  alias meteor="/usr/share/meteor/meteor"
fi

grep Meteor $DIR/dp.cfg 2>/dev/null || echo Meteor >> $DIR/dp.cfg
