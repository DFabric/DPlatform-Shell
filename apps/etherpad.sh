#!/bin/sh

. ../sysutils/nodejs.sh

if $PKG = apt
  then apt-get install gzip git curl python libssl-dev pkg-config build-essential
elif $PKG = rpm
  then yum install gzip git curl python openssl-devel && yum groupinstall "Development Tools"
fi
git clone git://github.com/ether/etherpad-lite.git
cd etherpad-lite
bin/run.sh

whiptail --msgbox "Etherpad successfully installed!

To start Etherpad, run 'cd etherpad-lite && bin/run.sh'

Open http://127.0.0.1:9001 in your browser." 20 80
