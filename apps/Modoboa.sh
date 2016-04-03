#!/bin/sh

$install git

cd
git clone https://github.com/modoboa/modoboa-installer
cd modoboa-installer

# Access the web GUI from other computers
sed -i 's/127.0.0.1/0.0.0.0/g' installer.cgf

./run.py `hostname`

whiptail --msgbox "Modoboa installed!

You should be able to access Modoboa at http://$URL:8000

Username: admin
Password: password" 14 64
