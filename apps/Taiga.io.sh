#!/bin/sh

cd
git clone https://github.com/taigaio/taiga-scripts
cd taiga-scripts
# Delete "exit" to remove root protection
sed -i '/exit 1/' setup-server.sh
bash setup-server.sh

whiptail --msgbox "Taiga.Io installed!

Open http://$URL:8000 in your browser to access to Taiga.Io" 12 64
