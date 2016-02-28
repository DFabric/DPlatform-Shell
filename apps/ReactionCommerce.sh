#!/bin/sh

if [ $1 = update ]
then
  cd ~/reaction
  ./reaction pull
  whiptail --msgbox "ReactionCommerce updated!" 8 32
  break
fi
[ $1 = remove ] && rm -rf agar.io-clone && sh sysutils/supervisor remove ReactionCommerce && whiptail --msgbox "ReactionCommerce removed!" 8 32 && break

# ARM architecture not supported
if [ $ARCH = arm ] || [ $ARCH = armv6 ]
then
  whiptail --yesno "Your architecture ($ARCH) isn't supported" 8 32
  [ $? = 1 ] &&	sed -i "/\bReactionCommerce\b/d" installed-apps && break
fi

. sysutils/NodeJS.sh
. sysutils/Meteor.sh

cd
# Install Reaction
git clone https://github.com/reactioncommerce/reaction

# Start the latest release
cd reaction
git checkout master # default branch is development

./reaction install

# Add supervisor process and run the server
sh $DIR/sysutils/supervisor.sh ReactionCommerce ".$HOME/reaction/reaction" $HOME/reaction

whiptail --msgbox "Reaction Commerce successfully installed!

Open http://$IP:3000 in your browser" 10 64
