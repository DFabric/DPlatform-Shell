#!/bin/sh

[ "$1" = update ] && { .$HOME/reaction pull; whiptail --msgbox "ReactionCommerce updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove ReactionCommerce; rm -rf ~/reaction; whiptail --msgbox "ReactionCommerce removed." 8 32; break; }

# ARM architecture not supported
if [ $ARCHf = arm ] ;then
  whiptail --yesno "Your architecture $ARCHf isn't supported" 8 32
  [ $? = 1 ] &&	sed -i "/ReactionCommerce/d" dp.cfg
  break
fi

. sysutils/Node.js.sh
. sysutils/Meteor.sh

cd
# Install Reaction
git clone https://github.com/reactioncommerce/reaction

# Start the latest release
cd reaction
git checkout master # default branch is development

./reaction install

# Add a systemd service and run the server
sh $DIR/sysutils/service.sh ReactionCommerce "$HOME/reaction/reaction" $HOME/reaction/bin

whiptail --msgbox "Reaction Commerce installed!

Open http://$URL:3000 in your browser" 10 64
