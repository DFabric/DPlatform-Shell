#!/bin/sh

cd
git clone https://github.com/taigaio/taiga-scripts
cd taiga-scripts

$install build-essential binutils-doc autoconf flex bison libjpeg-dev
$install libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev
$install automake libtool libffi-dev curl git tmux gettext
$install postgresql-9.4 postgresql-contrib-9.4
$install postgresql-doc-9.4 postgresql-server-dev-9.4
$install python3 python3-pip python-dev python3-dev python-pip virtualenvwrapper
$install libxml2-dev libxslt-dev

# Delete "exit" to remove root protection
sed -i '/exit 1/d' setup-server.sh
bash setup-server.sh

whiptail --msgbox "Taiga.Io successfully installed!

Open http://$IP:8000 in your browser to access to Taiga.Io" 12 64
