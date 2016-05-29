#!/bin/sh

[ $1 = update ] && { .$HOME/reaction pull; whitpail --msgbox "ReactionCommerce updated!" 8 32; exit; }
[ $1 = remove ] && { sh sysutils/service.sh remove ReactionCommerce; rm -rf ~/reaction; whitpail --msgbox "ReactionCommerce removed!" 8 32; exit; }

# ARM architecture not supported
if [ $ARCHf = arm ] ;then
  whiptail --yesno "Your architecture $ARCHf isn't supported" 8 32
  [ $? = 1 ] &&	sed -i "/ReactionCommerce/d" dp.cfg
  break
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

# Add SystemD process and run the server
sh $DIR/sysutils/service.sh ReactionCommerce "$HOME/reaction/reaction" $HOME/reaction/bin

whiptail --msgbox "Reaction Commerce installed!

Open http://$URL:3000 in your browser" 10 64
