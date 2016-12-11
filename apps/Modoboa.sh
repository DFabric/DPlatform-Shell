#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; break; }
[ "$1" = remove ] && { whiptail --msgbox "Not available yet." 8 32; break; }

$install python

cd
git clone https://github.com/modoboa/modoboa-installer
cd modoboa-installer

./run.py $(hostname)

whiptail --msgbox "Modoboa installed!

You should be able to access Modoboa at https://$URL

Username: admin
Password: password" 14 64
