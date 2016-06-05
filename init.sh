#!/bin/sh

# Detect distribution
. /etc/os-release

# Detect package manager
if hash apt-get 2>/dev/null ;then
	install="debconf-apt-progress -- apt-get install -y"
elif hash rpm 2>/dev/null ;then
	install="yum install -y"
	[ $ID = Fedora ] && install="dnf install -y" && remove="dnf remove -y"
elif hash pacman 2>/dev/null ;then
	install="pacman -S"
else
  echo "Your operating system $DIST isn't supported"; exit 1
fi

# Prerequisites
hash git whiptail curl wget pv sudo || $install git whiptail curl wget pv sudo

# Current directory
DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

# Check available updates or clone the project
[ "${DIR##*/}" = DPlatform-ShellCore ] && git pull
[ "${DIR##*/}" != DPlatform-ShellCore ] && git clone -b master --single-branch https://github.com/DFabric/DPlatform-ShellCore && DIR=$DIR/DPlatform-ShellCore

. $DIR/dplatform.sh
