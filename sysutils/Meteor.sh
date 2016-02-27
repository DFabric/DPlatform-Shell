#!/bin/sh

# Install Meteor
if [ $ARCH = amd64 ] || [ $ARCH = 86 ]
  then curl https://install.meteor.com | /bin/sh

# https://github.com/4commerce-technologies-AG/meteor
elif [ $ARCH = arm ] || [ $ARCH = armv6 ]
then
  cd
  git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor.git
  # Check installed version, try to download a compatible pre-built dev_bundle and finish the installation
  meteor/meteor --version

  # Set an alias
  alias meteor="$HOME/meteor/meteor"

  # Copy meteor binary to /bin
  cp ~/meteor/meteor /bin
fi
