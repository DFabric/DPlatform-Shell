#!/bin/sh
#https://github.com/anselal/wekan

cd
wget https://raw.githubusercontent.com/anselal/wekan/master/autoinstall_wekan.sh
chmod +x autoinstall_wekan.sh
./autoinstall_wekan.sh
rm https://raw.githubusercontent.com/anselal/wekan/master/autoinstall_wekan.sh

# Start the service
/etc/init.d/wekan start

whiptail --msgbox "Wekan successfully installed!

Start the service: /etc/init.d/wekan start

You can access your fresh wekan installation by pointing your browser to http://$IP:8080

Thanks to https://github.com/anselal/wekan" 16 64
