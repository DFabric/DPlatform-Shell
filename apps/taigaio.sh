#!/bin/sh

git clone https://github.com/taigaio/taiga-scripts.git
cd taiga-scripts
bash setup-server.sh

whiptail --msgbox "Taiga.Io successfully installed!

Open http://$IP:8000 in your browser to access to Taiga.Io" 12 64
