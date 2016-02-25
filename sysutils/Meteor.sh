#!/bin/sh

# Install Meteor
# https://github.com/4commerce-technologies-AG/meteor
if [ $ARCH = arm ] || [ $ARCH = armv6 ]
then
  cd $HOME
  git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor.git
  # Check installed version, try to download a compatible pre-built dev_bundle and finish the installation
  meteor/meteor --version
  cd $DIR

  # Set an alias
  alias meteor="$HOME/meteor/meteor"

  # Copy meteor binary to /bin
  cp $HOME/meteor/meteor /bin

else
  curl https://install.meteor.com | /bin/sh
fi
