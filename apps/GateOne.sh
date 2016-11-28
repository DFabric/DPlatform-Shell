#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet" 8 32; exit; }
[ "$1" = remove ] && { sh sysutils/service.sh remove GateOne; rm /etc/systemd/system/gateone.service; rm -rf /var/lib/gateone; rm -f /usr/local/bin/gateone; whiptail --msgbox "GateOne removed." 8 32; break; }

$install python

# Clone the repository
git clone https://github.com/liftoff/GateOne

cd GateOne
python setup.py install

# Start the service and enable it to start at boot
systemctl start gateone
systemctl enable gateone

whiptail --msgbox "GateOne installed!

The game is accessible at https://$URL" 10 64
