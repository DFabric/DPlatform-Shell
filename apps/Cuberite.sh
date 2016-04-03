#!/bin/sh

sh -c "$(wget -O - https://raw.githubusercontent.com/cuberite/cuberite/master/easyinstall.sh)"

whiptail --msgbox "Cuberite installed!

You might need to open the Minecraft 25565 port

WebAdmin at http://$URL:8080" 12 64
