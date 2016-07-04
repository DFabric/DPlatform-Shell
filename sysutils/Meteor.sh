#!/bin/sh

[ $1 = update ] && [ $ARCHf = arm ] && { git -C ~/meteor pull; whiptail --msgbox "Meteor updated!" 8 32; exit; }
[ $1 = update ] &&  $ARCHf = x86 ] && { curl https://install.meteor.com | /bin/sh; whiptail --msgbox "Meteor updated!" 8 32; exit; }
[ $1 = remove ] && [ $ARCHf = arm ] && { rm -rf /usr/share/meteor; whiptail --msgbox "Meteor removed!" 8 32; exit; }
[ $1 = remove ] && { rm -rf ~/.meteor; whiptail --msgbox "Meteor removed!" 8 32; exit; }

if [ -d ~./meteor ] || [ -d /usr/share/meteor ] ;then
  echo "You have Meteor installed"
# Install Meteor
elif [ $ARCHf = x86 ] ;then
  curl https://install.meteor.com | /bin/sh

# https://github.com/4commerce-technologies-AG/meteor
elif [ $ARCHf = arm ] ;then
  cd /usr/share
  git clone --depth 1 -b release-1.2.1-universal https://github.com/4commerce-technologies-AG/meteor

  # Fix curl CA error
  echo insecure > ~/.curlrc
  # Check installed version, try to download a compatible pre-built dev_bundle and finish the installation
  /usr/share/meteor/meteor -v
  rm ~/.curlrc

  # Set an alias
  alias meteor="/usr/share/meteor/meteor"
fi

grep Meteor $DIR/dp.cfg 2>/dev/null || echo Meteor >> $DIR/dp.cfg
