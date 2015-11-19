#!/bin/sh

$install git
git clone https://github.com/modoboa/modoboa-installer
cd modoboa-installer
./run.py 127.0.0.1

freshclam
service clamav-daemon restart

whiptail --msgbox "Modoboa successfully installed!

You should be able to access Modoboa at http://$DOMAIN:8000

Your installation should now have a default super administrator:

    Username: admin
    Password: password" 16 64
