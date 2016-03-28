#!/bin/sh

$install unzip nginx

cd
mkdir /var/www/laverna

# Download
wget https://github.com/Laverna/static-laverna/archive/gh-pages.zip

# Unpack the downloaded archive
unzip laverna.zip -C /var/www/laverna
rm laverna.zip

whiptail --msgbox "Laverna installed!

Open http://$IP in your browser" 12 48
