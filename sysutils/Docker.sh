#!/bin/sh

[ $1 = update ] && ($install docker || $install docker.io) && whiptail --msgbox "Docker updated!" 8 32 && exit
[ $1 = remove ] && ($remove docker || $remove docker.io) && whiptail --msgbox "Docker removed!" 8 32 && exit

# Get the latest Docker package.
hash docker 2>/dev/null && echo Docker is already installed || [ $ARCH = amd64 ] && wget -qO- https://get.docker.com/ | sh || $install docker.io

grep Docker dp.cfg 2>/dev/null || echo Docker >> dp.cfg
