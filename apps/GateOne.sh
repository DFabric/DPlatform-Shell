#!/bin/sh

[ $1 = update ] && { whiptail --msgbox "Not available" 8 32; exit; }
[ $1 = remove ] && { sh sysutils/service.sh remove GateOne; rm -rf /var/lib/gateone; rm -f /usr/local/bin/gateone; whiptail --msgbox "GateOne  updated!" 8 32; break; }

$install python

# Clone the repository
git clone https://github.com/liftoff/GateOne

cd GateOne
python setup.py install
mv /lib/systemd/system/gateone.service /etc/systemd/system

# Start the service and enable it to start on boot
systemctl start gateone
systemctl enable gateone

whiptail --msgbox "GateOne installed!

The game is accessible at https://$URL" 10 64
