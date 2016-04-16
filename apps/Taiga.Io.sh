#!/bin/sh

# Dependencies
$install build-essential binutils-doc autoconf flex bison libjpeg-dev \
libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev libxml2 \
automake libtool libffi-dev curl git tmux \
python3 python3-pip python-dev python3-dev python-pip virtualenvwrapper \
postgresql-9.4 postgresql-contrib-9.4 postgresql-server-dev-9.4
# (needs >= 9.3)

cd
git clone https://github.com/taigaio/taiga-scripts
cd taiga-scripts
# Delete "exit" to remove root protection
sed -i '/exit 1/d' setup-server.sh
bash setup-server.sh

whiptail --msgbox "Taiga.Io installed!

Open http://$URL:8000 in your browser to access to Taiga.Io" 12 64
