#!/bin/sh
# DeployPlaform - Deploy self-hosted apps efficiently
# https://github.com/j8r/DPlatform
# Copyright (c) 2015-2016 Julien Reichardt - MIT License (MIT)

# This script is implemented as POSIX-compliant.
# It should work on sh, dash, bash, ksh, zsh on Debian, Ubuntu, CentOS
# and probably other distros of the same families, although no support is offered for them.

# Actual directory
DIR=$(cd -P $(dirname $0) && pwd)

# Check if a new version is available
cd $DIR
git pull
touch installed-apps

# Detect IP
IPv4=$(wget -qO- ipv4.icanhazip.com) #$(wget -qO- http://ip4.cuby-hebergs.com/)
IPv6=$(ip addr | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | tail -n 2 | head -n 1)
LOCALIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
# Set default IP to IPv4 unless IPv6 is available
#[ $IPv6 = ::1 ] && IP=[$IPv4]

IP=$LOCALIP
DOMAIN=$(hostname)

# Detect distribution
. /etc/os-release
DIST=$ID
DIST_VER=$VERSION_ID
DIST_NAME=$PRETTY_NAME

# Detect package manager
if hash apt-get 2>/dev/null
	then PKG=deb
	install="debconf-apt-progress -- apt-get install -y"
	remove="apt-get purge -y"
elif hash rpm 2>/dev/null
	then PKG=rpm
	install="yum install --enablerepo=epel -y"
	remove="yum remove -y"
	[ $DIST = fedora ] && install="dnf install --enablerepo=epel -y" && remove="dnf remove -y"
elif hash pacman 2>/dev/null
	then PKG=pkg
	install="pacman -S"
else
	PKG=unknown
fi

# GConfigure default locale if not set
[ "$(perl -V:)" = "" ] || export LC_ALL=en_US.UTF-8

# Ckeck if curl is installed because it will be very used
hash curl 2>/dev/null || $install curl

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
	x86_64) ARCH=amd64;;
	i*86) ARCH=86;;
	armv8*) ARCH=arm; ARMv=arm64;;
	armv7*) ARCH=arm; ARMv=armv7;;
	armv6*) ARCH=arm; ARMv=armv6;;
	*) whiptail --msgbox "Your architecture $ARCH isn't supported" 8 48 exit;;
esac

# Detect hardware
HDWR=$(uname -a)
case "$HDWR" in
	*rpi2*) HDWR=rpi2;;
	*rpi*) HDWR=rpi;;
	*bananian*) HDWR=bpi;;
	*) HDWR=other;;
esac
# Applications installation menu
installation_menu() {
	if [ $1 = update ] || [ $1 = remove ]
	then
		# Reset previous apps_choice variable
		apps_choice=
		if [ $1 = update ]
			then apps_choice="Update Syncronize_new_packages_available"
		fi

		# Read installed-apps to create entries
		while read app
		do
			apps_choice="$apps_choice $app $1_$app"
		done < installed-apps

		while whiptail --title "DPlatform - $1 menu" --menu "
		What application would you like to $1?" 16 64 8 $apps_choice 2> /tmp/temp
		do
			cd $DIR
			read CHOICE < /tmp/temp
			# Confirmation message
			whiptail --yesno "		$CHOICE will be $1d.
			Are you sure to want to continue?" 8 48
			case $? in
				1) ;; # Return to installation menu
				0)
				# Remove SytemD service and it's entry
				[ $1 = remove ] && (sh sysutils/services.sh remove $CHOICE; sed -i "/$CHOICE/d" installed-apps)
				case $CHOICE in
					Update) [ $PKG = deb ] && apt-get update
					[ $PKG = rpm ] && yum update;;
					Docker) . sysutils/Docker.sh $1;;
					Meteor) . sysutils/Meteor.sh $1;;
					MongoDB) . sysutils/MongoDB.sh $1;;
					Node.js) . sysutils/NodeJS.sh $1;;
					$CHOICE) . apps/$CHOICE.sh $1;;
				esac;;
			esac
		done
	else
		while whiptail --title "DPlatform - Installation menu" --menu "
		What application would you like to deploy?" 24 96 14 \
		Rocket.Chat "The Ultimate Open Source WebChat Platform" \
		OpenVPN "Open source secure tunneling VPN daemon" \
		Mumble "Voicechat utility" \
		Syncthing "Open Source Continuous File Synchronization" \
		Seafile "Cloud storage with file encryption and group sharing" \
		Mopidy "Mopidy is an extensible music server written in Python" \
		OwnCloud "Access & share your files, calendars, contacts, mail" \
		Torrent "Deluge and Transmission torrent web interface" \
		Agar.io-Clone "Agar.io clone written with Socket.IO and HTML5 canvas" \
		Ajenti "Web admin panel" \
		Cuberite "A custom Minecraft compatible game server written in C++" \
		Docker "Open container engine platform for distributed application" \
		EtherCalc "Web spreadsheet, Node.js port of Multi-user SocialCalc" \
		EtherDraw "Collaborative real-time drawing, sketching & painting" \
		Etherpad "Real-time collaborative document editor" \
		GitLab "Open source Version Control to collaborate on code" \
		Ghost "Simple and powerful blogging/publishing platform" \
		Gogs "Gogs(Go Git Service), a painless self-hosted Git Service" \
		Jitsi-Meet "Secure, Simple and Scalable Video Conferences" \
		JS_Bin "Collaborative JavaScript Debugging App" \
		KeystoneJS "|~| Node.js CMS & Web Application Platform" \
		Laverna "/!\ Note taking application with Mardown editor and encryption" \
		LetsChat "Self-hosted chat app for small teams" \
		Linx "Self-hosted file/code/media sharing website" \
		Mailpile "Modern, fast email client with user-friendly privacy features" \
		Mattermost "/!\ Mattermost is an open source, on-prem Slack-alternative" \
		Meteor "The JavaScript App Platform" \
		Modoboa "/!\ Mail hosting made simple" \
		MongoDB "The next-generation database" \
		Node.js "Install Node.js using nvm" \
		NodeBB "Node.js based community forum built for the modern web" \
		ReactionCommerce "/!\ Modern reactive, real-time event driven ecommerce platform." \
		RetroPie "/!\ Setup Raspberry PI with RetroArch emulator and various cores" \
		Shout "The self-hosted web IRC client" \
		StackEdit "/!\ In-browser markdown editor" \
		Stringer "/!\ A self-hosted, anti-social RSS reader" \
		Taiga.Io "/!\ Agile, Free and Open Source Project Management Platform" \
		Wagtail "|~| Django CMS focused on flexibility and user experience" \
		Wekan "/!\ Collaborative Trello-like kanban board application" \
		Wide "|~| Web-based IDE for Teams using Go(lang)" \
		WP-Calypso "|~| Reading, writing, and managing all of your WordPress sites" \
		Dillinger "|~| The last Markdown editor, ever" \
		2> /tmp/temp
		do
			cd $DIR
			read CHOICE < /tmp/temp
			# Confirmation message
			whiptail --yesno "		$CHOICE will be installed.
			Are you sure to want to continue?" 8 48
			case $? in
				1) ;; # Return to installation menu
				0)
				case $CHOICE in
					Docker) . sysutils/Docker.sh;;
					Meteor) . sysutils/Meteor.sh;;
					MongoDB) . sysutils/MongoDB.sh;;
					Node.js) . sysutils/NodeJS.sh;;
					$CHOICE) . apps/$CHOICE.sh; grep $CHOICE $DIR/installed-apps || echo $CHOICE >> $DIR/installed-apps;;
				esac;;
			esac
		done
	fi
}

# Configuration Entry
if [ $HDWR = rpi ] || [ $HDWR = rpi2 ]
then
	config=raspi-config
	configOption=" Raspberry_Pi_Configuration_Tool"
elif [ $HDWR = bpi ]
then
	config=bananian-config
	configOption=" Banana_Pi_Configuration_Tool"
fi

# Main menu
while whiptail --title "DPlatform - Main menu" --menu "	Select with Arrows <-v-> and Tab <=>. Confirm with Enter <-'" 16 96 8 \
"Install apps" "Install new applications" \
"Update" "Update applications and DPlatform" \
"Remove apps" "Uninstall applications" \
"Apps Service Manager" "Start/Stop and auto start services at startup" \
"Domain name" "Set a domain name to use a name instead of the computer's IP address" \
"About" "Informations about this project and your system" \
$config${configOption} 2> /tmp/temp
do
	cd $DIR
	read CHOICE < /tmp/temp
	case $CHOICE in
		$config) $config;;
		"Install apps") installation_menu install;;
		Update) installation_menu update;;
		"Remove apps") installation_menu remove;;
		"Apps Service Manager") . sysutils/services.sh;;
		"Domain name") . sysutils/domain-name.sh;;
		About) whiptail --title "DPlatform - About" --msgbox "DPlatform - Deploy self-hosted apps easily
		https://github.com/j8r/DPlatform
		- Your host/domain name: $DOMAIN
		- Your local IPv4: $LOCALIP
		- Your public IPv4: $IPv4
		- Your IPv6: $IPv6
		Your OS: $ARCH arch $PKG based $DIST_NAME
		Copyright (c) 2015-2016 Julien Reichardt - MIT License (MIT)
		DPlatform is distributed under the [MIT License]" 16 64;;
	esac
done
