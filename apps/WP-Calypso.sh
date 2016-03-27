#!/bin/sh

#https://github.com/Automattic/wp-calypso/blob/master/docs/install.md

# Prerequisites
. sysutils/NodeJS.sh

$install git make

cd
# Installing and Running
git clone https://github.com/Automattic/wp-calypso
cd wp-calypso
make run

# Add 127.0.0.1 calypso.localhost to your local hosts file
echo 127.0.0.1 calypso.localhost >> /etc/hosts

whiptail --msgbox "Wordpress Calypso installed!

Open http://calypso.$IP:3000 in your browser" 10 64
