#!/bin/sh

[ $1 = update ] && [ $ARCH = arm ] && (cd ~/meteor; git pull) && whiptail --msgbox "Meteor updated!" 8 32 && break
[ $1 = remove ] && whiptail --msgbox "Not availabe yet!" 8 32 && echo Meteor >> installed-apps && break

# Install Meteor
if [ $ARCH = amd64 ] || [ $ARCH = 86 ]
  then curl https://install.meteor.com | /bin/sh

# https://github.com/4commerce-technologies-AG/meteor
elif [ $ARCH = arm ]
then
  cd
  git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor

  # Fix curl CA error
  echo insecure > ~/.curlrc
  # Check installed version, try to download a compatible pre-built dev_bundle and finish the installation
  ~/meteor/meteor -v
  rm ~/.curlrc

  # Set an alias
  alias meteor="$HOME/meteor/meteor"

  # Copy meteor binary to /bin
  cp ~/meteor/meteor /bin
fi

grep Meteor installed-apps || echo Meteor >> installed-apps
