#!/bin/sh
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install docker-engine
service docker start

# Uninstall
uninstall) {apt-get autoremove --purge docker-engine
rm -rf /var/lib/docker;;
}
