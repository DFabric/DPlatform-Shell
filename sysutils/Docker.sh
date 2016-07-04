#!/bin/sh

[ $1 = update ] && { [ $ARCH = amd64 ] && $install docker-engine || $install docker.io || $install docker; whiptail --msgbox "Docker updated!" 8 32; exit; }
[ $1 = remove ] && { [ $ARCH = amd64 ] && $remove docker-engine || $remove docker.io || $remove docker; whiptail --msgbox "Docker removed!" 8 32; exit; }

# Get the latest Docker package.
hash docker 2>/dev/null && echo Docker is already installed || [ $ARCH = amd64 ] && wget -qO- https://get.docker.com/ | sh || $install docker.io || $install docker

grep Docker dp.cfg 2>/dev/null || echo Docker >> dp.cfg
