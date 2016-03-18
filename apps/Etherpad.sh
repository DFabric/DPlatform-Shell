#!/bin/sh

if [ $1 = update ]
then
  cd ~/etherpad-lite
  git pull
  whiptail --msgbox "Etherpad updated!" 8 32
  break
fi
[ $1 = remove ] && sh sysutils/services.sh remove Etherpad && rm -rf etherpad-lite && whiptail --msgbox "Etherpad removed!" 8 32 && break

. sysutils/NodeJS.sh

cd
# gzip, git, curl, libssl develop libraries, python and gcc needed
if [ $PKG = apt ]
  then apt-get install gzip git curl python libssl-dev pkg-config build-essential
elif [ $PKG = rpm ]
  then yum install gzip git curl python openssl-devel && yum groupinstall "Development Tools"
fi
git clone https://github.com/ether/etherpad-lite

# Add SystemD process and run the server
sh $DIR/sysutils/services.sh Etherpad ".$HOME/etherpad-lite/bin/run.sh --root" $HOME/etherpad-lite

whiptail --msgbox "Etherpad successfully installed!

Open http://$IP:9001 in your browser." 10 64
