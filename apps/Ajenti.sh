#!/bin/sh
curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh > install.sh && bash install.sh

# Start the service:
#/etc/init.d/ajenti start

whiptail --msgbox "Ajenti successfully installed!

Open http://$IP:8000 in your browser

service ajenti {start|restart|stop}" 12 48
