#!/bin/sh

# Detect distribution
. /etc/os-release

# Detect package manager
if hash apt-get 2>/dev/null ;then
	PKG=deb
	install="debconf-apt-progress -- apt-get install -y"
	remove="apt-get purge -y"
elif hash dnf 2>/dev/null ;then
	PKG=rpm
	install="dnf install -y"
	remove="dnf remove -y"
elif hash yum 2>/dev/null ;then
	PKG=rpm
	install="yum install -y"
	remove="yum remove -y"
elif hash pacman 2>/dev/null ;then
	PKG=pkg
	install="pacman -Syu"
	remove="pacman -Rsy"
else
	echo "Your operating system $DIST isn't supported" 8 48; exit 1
fi

# Prerequisites
hash git whiptail curl wget sudo || $install git whiptail curl wget sudo

# Current directory
DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

# Check available updates or clone the project
[ -d $DIR/.git ] && git pull
[ -d $DIR/DPlatform-ShellCore ] && DIR=$DIR/DPlatform-ShellCore || [ "${DIR##*/}" != DPlatform-ShellCore ] && git clone -b master --single-branch https://github.com/DFabric/DPlatform-ShellCore && DIR=$DIR/DPlatform-ShellCore
. $DIR/dplatform.sh
