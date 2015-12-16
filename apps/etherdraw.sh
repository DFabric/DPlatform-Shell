#!/bin/sh

# Install Requirements
$install libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++

# Install EtherDraw
git clone git://github.com/JohnMcLear/draw.git

cd draw
bin/run.sh

whiptail --msgbox "EtherDraw successfully installed!

Open http://$IP:9002 in your browser and make a drawing\!" 10 64
