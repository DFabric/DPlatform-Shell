#!/bin/sh

$install unzip

cd
# Download
wget https://github.com/Laverna/static-laverna/archive/gh-pages.zip -O laverna.zip

# Unpack the downloaded archive
unzip laverna.zip

whiptail --msgbox "Laverna installed!

Open http://$IP in your browser" 12 48
