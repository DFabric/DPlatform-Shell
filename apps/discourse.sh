#!/bin/sh

mkdir /var/discourse
git clone https://github.com/discourse/discourse_docker.git /var/discourse
cd /var/discourse
cp samples/standalone.yml containers/app.yml




    Create an empty swapfile

    sudo install -o root -g root -m 0600 /dev/null /swapfile

    write out a 1 GB file named 'swapfile'

    dd if=/dev/zero of=/swapfile bs=1k count=1024k

    if you want it to be 2 GB

    dd if=/dev/zero of=/swapfile bs=1k count=2048k

    tell linux this is the swap file:

    mkswap /swapfile

    Activate it

    swapon /swapfile

    Add it to the file system table so its there after reboot:

    echo "/swapfile       swap    swap    auto      0       0" | sudo tee -a /etc/fstab

    Set the swappiness to 10 so its only uses as an emergency buffer

    sudo sysctl -w vm.swappiness=10
    echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf

The whole thing as a single copy and pastable script that creates a 2GB swapfile:

sudo install -o root -g root -m 0600 /dev/null /swapfile
dd if=/dev/zero of=/swapfile bs=1k count=2048k
mkswap /swapfile
swapon /swapfile
echo "/swapfile       swap    swap    auto      0       0" | sudo tee -a /etc/fstab
sudo sysctl -w vm.swappiness=10
echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
