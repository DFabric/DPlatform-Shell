#!/bin/sh

git clone https://github.com/taigaio/taiga-scripts.git
cd taiga-scripts
bash setup-server.sh

whiptail --msgbox "Taiga.Io successfully installed!

Open http://your_local_ip:8000 in your browser to access to Taiga.Io" 16 60
