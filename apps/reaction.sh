#!/bin/sh

. sysutils/nodejs.sh
. sysutils/meteor.sh

cd ~
# Install Reaction
git clone https://github.com/reactioncommerce/reaction.git

# Start the latest release
cd reaction && git checkout master # default branch is development
./reaction

whiptail --msgbox "Reaction Commerce successfully installed!
To run Reaction:
cd reaction
./reaction

Open http://$IP:3000 in your browser" 12 64
