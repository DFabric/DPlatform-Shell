#!/bin/sh
# DeployPlaform - Deploy self-hosted apps efficiently
# https://github.com/DFabric/DPlatform-ShellCore
# Copyright (c) 2015-2016 Julien Reichardt - MIT License (MIT)

# This script is implemented as POSIX-compliant.
# It should work on sh, dash, bash, ksh, zsh on Debian, Ubuntu, Fedora, CentOS
# and probably other distros of the same families, although no support is offered for them.

end="\33[0m"

# Bold Yellow selectioned color
cl="\33[1;33m"

if [ "$1" != run ] ;then
	printf "To run tests: sh dplatform.sh run

	You can use systemd-nspawn to launch DPlatform tests inside

	$cl Unbuntu 16.04$end
	machinectl pull-tar https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-root.tar.xz
	systemd-nspawn -M xenial-server-cloudimg-amd64-root
	# If you have no DNS, copy /etc/resolv.conf of your machine to /run/resolvconf/resolv.conf in the container

	$cl Fedora 25$end
	machinectl pull-raw --verify=no https://dl.fedoraproject.org/pub/fedora/linux/releases/25/CloudImages/x86_64/images/Fedora-Cloud-Base-25-1.3.x86_64.raw.xz
	systemd-nspawn -M Fedora-Cloud-Base-25-1.3.x86_64\n"
	exit 0
fi
[ $(id -u) != 0 ] && printf "\033c\33[1;31m        You don't run this as root!\33[0m
    You will need to have root permissions
    Press Enter <-'\n" && read null

# cd to the current directory
cd $(cd -P $(dirname $0) && pwd)

cp -r .. /tmp/DPlatform-ShellCore-test
DIR=/tmp/DPlatform-ShellCore-test
cd $DIR

# Detect distribution
if [ -e /etc/os-release ] ;then
	. /etc/os-release
	DIST=$ID
	DIST_VER=$VERSION_ID
elif [ -e /etc/issue ] ;then
	grep -q Red Hat /etc/issue && DIST=redhat
	grep -q CentOS /etc/issue && DIST=centos
	DIST_VER=$(cat /etc/issue)
	DIST_VER=${DIST_VER#*release}
	DIST_VER=${DIST_VER%.*}
else
	echo "Your operating system $DIST isn't supported" 8 48; exit 1
fi

# Detect package manager
if hash apt-get 2>/dev/null ;then
	PKG=deb
	install="apt-get install -y"
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
	echo "Your operating system $DIST isn't supported"; exit 1
fi

# Prerequisites
hash git curl wget 2>/dev/null || $install git curl wget

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
	x86_64) ARCHf=x86; ARCH=amd64;;
	i*86) ARCHf=x86; ARCH=86;;
	aarch64) ARCHf=arm; ARCH=arm64;;
	armv7*) ARCHf=arm; ARCH=armv7;;
	armv6*) ARCHf=arm; ARCH=armv6;;
	*) echo "Your architecture $ARCH isn't supported"; exit 1;;
esac

# Check if systemd is the init system
hash systemctl 2>/dev/null || echo '	/!\ WARNING - systemd services not available /!\

	You do not have systemd as an init system.
Your apps will be installed successfully but you will not
be able to use custom app services that run in the background'

# Test if cuby responds
echo "Obtaining the IPv4 address from http://ip4.cuby-hebergs.com..."
IPv4=$(wget -qO- http://ip4.cuby-hebergs.com && sleep 1) && echo "done." || echo "failed"
# Else use this site
[ "$IPv4" = "" ] && { echo "Can't retrieve the IPv4 from cuby-hebergs.com.\nTrying to obtaining the IPv4 address from ipv4.icanhazip.com..." && IPv4=$(wget -qO- ipv4.icanhazip.com && sleep 1) && echo "done." || echo "failed."; }

# Check Internet availability
ping -c 1 g.co >/dev/null 2>&1 || echo '	/!\ WARNING - No Internet Connection /!\
You have no internet connection. You can do everything but install new apps'

IPv6=$(ip addr | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | tail -n 2 | head -n 1)

LOCALIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)

# Download with progress bar
download() {
	echo $2
	wget $1
}

# Extract with progress bar
extract() {
	echo $3
	tar $2 -${1% *}
}

URL=$(hostname)
IP=$LOCALIP
APP_LIST="Rocket.Chat Gogs Syncthing OpenVPN Mumble Seafile Mopidy FreshRSS OwnCloud Nextcloud Agar.io-Clone Ajenti Cuberite Deluge Dillinger Droppy EtherCalc EtherDraw Etherpad GateOne Gitea GitLab Ghost Jitsi-Meet JSBin KeystoneJS Laverna LetsChat Linx Cloud9 Curvytron Caddy Docker Mailpile Mattermost Meteor Modoboa MongoDB netdata Node.js NodeBB ReactionCommerce TheLounge StackEdit Taiga.io Transmission Wagtail Wekan Wide WordPress WP-Calypso"

# Port
sed -i -e '/Set a port/ s/=.*"\(.*\)"[^"]*$/=\1/' $DIR/*/*

# Message box
sed -i -e 's/whiptail --msgbox/echo/' -e 's/" [0-9]*[0-9] [0-9][0-9]/"/' $DIR/*/*

for app in $APP_LIST ;do
	app_path="$DIR/apps/$app.sh"
	case $app in
		Caddy|Docker|Meteor|MongoDB|Node.js) app_path="$DIR/sysutils/$app.sh";;
		Rocket.Chat) sed -i -n '/while/{:a;N;/done/!ba;N;s/.*/MONGO_URL=MONGO_URL=mongodb:\/\/127.0.0.1:27017\/rocketchat\n. $DIR\/sysutils\/MongoDB.sh\n/};p' $app_path;;
		$app) ;;
	esac

	if [ "$1" = update ] || [ "$1" = remove ] ;then
		for a in a; do . $app_path $1 ;done
	else
		. $app_path
	fi
	cd $DIR
done

rm -r $DIR
