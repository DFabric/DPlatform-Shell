#!/bin/sh
# DeployPlaform - Deploy self-hosted apps efficiently
# https://github.com/DFabric/DPlatform-ShellCore
# Copyright (c) 2015-2016 Julien Reichardt - MIT License (MIT)

# This script is implemented as POSIX-compliant.
# It should work on sh, dash, bash, ksh, zsh on Debian, Ubuntu, Fedora, CentOS
# and probably other distros of the same families, although no support is offered for them.

export DIRIPv4 IPv6 LOCALIP DIST DIST_VER PKG install remove ARCH ARCHf HDWR URL IP

# Current directory
[ "$DIR" = '' ] && DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

# Test if cuby responds
IPv4=$(wget -qO- http://ip4.cuby-hebergs.com/ && sleep 1)
# Else use this site
[ "$IPv4" = "" ] && IPv4=$(wget -qO- ipv4.icanhazip.com && sleep 1)
[ "$IPv4" = "" ] && whiptail --title '/!\ WARNING - No Internet Connection /!\' --msgbox "\
You have no internet connection. You can do everything but install new apps and access them through Internet" 10 48

IPv6=$(ip addr | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | tail -n 2 | head -n 1)
LOCALIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
# Detect distribution
. /etc/os-release
DIST=$ID
DIST_VER=$VERSION_ID

# Detect package manager
if hash apt-get 2>/dev/null ;then
	PKG=deb
	install="debconf-apt-progress -- apt-get install -y"
	remove="apt-get purge -y"
elif hash rpm 2>/dev/null ;then
	PKG=rpm
	install="yum install --enablerepo=epel -y"
	remove="yum remove -y"
	[ $DIST = Fedora ] && install="dnf install --enablerepo=epel -y" && remove="dnf remove -y"
elif hash pacman 2>/dev/null ;then
	PKG=pkg
	install="pacman -S"
else
	whiptail --msgbox "Your operating system $DIST isn't supported" 8 48; exit 1
fi

# Prerequisites
hash whiptail curl wget pv sudo || $install whiptail wget curl pv sudo

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
	x86_64) ARCHf=x86; ARCH=amd64;;
	i*86) ARCHf=x86; ARCH=86;;
	aarch64) ARCHf=arm; ARCH=arm64;;
	armv7*) ARCHf=arm; ARCH=armv7;;
	armv6*) ARCHf=arm; ARCH=armv6;;
	*) whiptail --msgbox "Your architecture $ARCH isn't supported" 8 48 exit 1;;
esac

# Detect hardware
HDWR=$(uname -a)
case "$HDWR" in
	*rpi2*) HDWR=rpi2;;
	*rpi*) HDWR=rpi;;
	*bananian*) HDWR=bpi;;
	*) HDWR=other;;
esac

# Domain configuration
network_access() {
	NET=$(whiptail --nocancel --title "DPlatform - First launch setup" --menu "Select with arrows <-v-> and Tab <=>. Confirm with Enter <-'
It appears that you run DPlatform for the first time. You need to setup the network access of your applications. \
You can change this setup anytime if you want a different access before installing new apps" 14 96 2 \
"Local" "Your apps will be available only in your local network / from your home" \
"Public IP/FQDN" "Only if you can open your ports / make redirections in your router firewall" 3>&1 1>&2 2>&3)
	#Worlwide with generrated URL" "Secure access with a generated/custom URL with a Firewall passthrough. No further configurations needed" \
	case $NET in
		"Local") whiptail --msgbox "You can access to your apps by opening >| $(hostname) |< in your browser. \
Howewer, it might not work depending of your local DNS configuration. \
You can always use the local IP of your server in your local network" 10 64
			sed -i "/URL=/URL=hostname/d" dp.cfg 2>/dev/null || echo "URL=hostname" > dp.cfg;;

		"Public IP/FQDN") whiptail --msgbox "You can access to your apps by opening >| $IP < in your browser." 8 64
			sed -i "/URL=/URL=IP/d" dp.cfg 2>/dev/null || echo "URL=IP" > dp.cfg;;
	esac
}

# Create a dp.cfg with a URL variable if it doesn't exist
[ -f dp.cfg ] || network_access

change_hostname() {
	new_hostname=$(whiptail --inputbox --title "Change your hostname" "\
	Your hostname must contain only ASCII letters 'a' through 'z' (case-insensitive),
the digits '0' through '9', and the hyphen.
Hostname labels cannot begin or end with a hyphen.
No other symbols, punctuation characters, or blank spaces are permitted.
Please enter a hostname:" 14 64 "$(hostname)" 3>&1 1>&2 2>&3)
	if [ $? = 0 ] ;then
		echo $new_hostname > /etc/hostname
		sed -i "s/ $($hostname) / $new_hostname /g" /etc/hosts
		whiptail --yesno "You need to reboot to apply the hostname change. Reboot now?" 8 32
		[ $? = 0 ] && reboot
	fi
}

# Applications menus
apps_menus() {
	if [ $1 = update ] || [ $1 = remove ] ;then
		# Reset previous apps_choice variable
		apps_choice=
		[ $1 = update ] && apps_choice="Update Syncronize_new_packages_available"

		# Read dp.cfg to create entries
		while read app ;do
			[ "$app" = "$(grep URL= dp.cfg)" ] || apps_choice="$apps_choice $app $1_$app"
		done < dp.cfg
		# Update and remove menu
		APP=$(whiptail --title "DPlatform - $1 menu" --menu "
		What application would you like to $1?" 16 64 8 $apps_choice 3>&1 1>&2 2>&3)
			# Confirmation message
			[ $? = 0 ] && whiptail --yesno "		$APP will be $1d.
			Are you sure to want to continue?" 8 48
			# Remove the app entry
			[ $? = 0 ] && case $APP in
				Update) [ $PKG = deb ] && apt-get update
				[ $PKG = rpm ] && yum update;;
				Caddy) . sysutils/Caddy.sh $1;;
				Docker) . sysutils/Docker.sh $1;;
				Meteor) . sysutils/Meteor.sh $1;;
				MongoDB) . sysutils/MongoDB.sh $1;;
				Node.js) . sysutils/NodeJS.sh $1;;
				$APP) sh apps/$APP.sh $1; [ $1 = remove ] && sed -i "/$APP/d" dp.cfg;;
			esac
		cd $DIR
	else
		# Installation menu
		while APP=$(whiptail --title "DPlatform - Installation menu" --menu "\
		What application would you like to deploy?
		Apps with /!\ are not finished, same with |~| but might works" 24 96 14 \
		Rocket.Chat "The Ultimate Open Source WebChat Platform" \
		Gogs "Gogs(Go Git Service), a painless self-hosted Git Service" \
		Syncthing "Open Source Continuous File Synchronization" \
		OpenVPN "Open source secure tunneling VPN daemon" \
		Mumble "Voicechat utility" \
		Seafile "Cloud storage with file encryption and group sharing" \
		Mopidy "Mopidy is an extensible music server written in Python" \
		FreshRSS "A free, self-hostable aggregator" \
		OwnCloud "Access & share your files, calendars, contacts, mail" \
		Agar.io-Clone "Agar.io clone written with Socket.IO and HTML5 canvas" \
		Ajenti "Web admin panel" \
		Cuberite "A custom Minecraft compatible game server written in C++" \
		Deluge "A lightweight, Free Software, cross-platform BitTorrent client" \
		Dillinger "The last Markdown editor, ever" \
		Droppy " Self-hosted file storage server, with file editing and media view" \
		EtherCalc "Web spreadsheet, Node.js port of Multi-user SocialCalc" \
		EtherDraw "Collaborative real-time drawing, sketching & painting" \
		Etherpad "Real-time collaborative document editor" \
		GitLab "Open source Version Control to collaborate on code" \
		Ghost "Simple and powerful blogging/publishing platform" \
		Jitsi-Meet "Secure, Simple and Scalable Video Conferences" \
		JSBin "Collaborative JavaScript Debugging App" \
		KeystoneJS "|~| Node.js CMS & Web Application Platform" \
		Laverna "Note taking application with Mardown editor and encryption" \
		LetsChat "Self-hosted chat app for small teams" \
		Linx "Self-hosted file/code/media sharing website" \
		Curvytron "A web multiplayer Tron-like game with curves" \
		Caddy "Fast, cross-platform HTTP/2 web server with automatic HTTPS" \
		Docker "Open container engine platform for distributed application" \
		Mailpile "Modern, fast email client with user-friendly privacy features" \
		Mattermost "/!\ Mattermost is an open source, on-prem Slack-alternative" \
		Meteor "The JavaScript App Platform" \
		Modoboa "/!\ Mail hosting made simple" \
		MongoDB "The next-generation database" \
		netdata "Real-time performance monitoring, in the greatest possible detail" \
		Node.js "Install Node.js using nvm" \
		NodeBB "Node.js based community forum built for the modern web" \
		ReactionCommerce "|~| Modern reactive, real-time event driven ecommerce platform" \
		RetroPie "/!\ Setup Raspberry PI with RetroArch emulator and various cores" \
		Shout "The self-hosted web IRC client" \
		StackEdit "In-browser markdown editor" \
		Feedbin "/!\ Feedbin is a simple, fast and nice looking RSS reader" \
		Stringer "/!\ A self-hosted, anti-social RSS reader" \
		Taiga.Io "/!\ Agile, Free and Open Source Project Management Platform" \
		Transmission "A cross-platform BitTorrent client that is easy and powerful use" \
		Wagtail "|~| Django CMS focused on flexibility and user experience" \
		Wekan "Collaborative Trello-like kanban board application" \
		Wide "|~| Web-based IDE for Teams using Go(lang)" \
		WordPress "Create a beautiful website, blog, or app" \
		WP-Calypso "|~| Reading, writing, and managing all of your WordPress sites" \
		3>&1 1>&2 2>&3) ;do
			# Confirmation message
			whiptail --yesno "		$APP will be installed.
			Are you sure to want to continue?" 8 48
			case $? in
				1) ;; # Return to installation menu
				0) if grep $APP dp.cfg 2>/dev/null ;then
					whiptail --msgbox "$APP is already installed" 8 32
				else
					case $APP in
						Caddy) . sysutils/Caddy.sh;;
						Docker) . sysutils/Docker.sh;;
						Meteor) . sysutils/Meteor.sh;;
						MongoDB) . sysutils/MongoDB.sh;;
						Node.js) . sysutils/NodeJS.sh;;
						$APP) . apps/$APP.sh; cd $DIR; grep $APP dp.cfg 2>/dev/null || echo $APP >> dp.cfg;;
					esac
				fi;;
			esac
		done
	fi
}

# Configuration Entry
if hash bananian-config 2>/dev/null ;then
	config=bananian-config
	configOption=" Banana_Pi_Configuration_Tool"
elif hash raspi-config 2>/dev/null ;then
	config=raspi-config
	configOption=" Raspberry_Pi_Configuration_Tool"
fi

while
# Recuperate the URL variable from dp.cfg
case $(grep URL= dp.cfg) in
	URL=hostname) URL=`hostname`; IP=$LOCALIP;;
	URL=IP) [ $IPv6 = ::1 ] && IP=$IPv4 || IP=[$IPv6]; URL=$IP;; # Set default IP to IPv4 unless IPv6 is available
esac
# Main menu
CHOICE=$(whiptail --title "DPlatform - Main menu" --menu "	Select with arrows <-v-> and Tab <=>. Confirm with Enter <-'
Your can access to your apps by opening this address in your browser:
		>| http://$URL(:port) |<" 18 80 8 \
"Install apps" "Install new applications" \
"Update" "Update applications and DPlatform" \
"Remove apps" "Uninstall applications" \
"Apps Service Manager" "Start/Stop and auto start services at startup" \
"Network app access" "Define the network accessibility of the apps" \
"Hostname" "Change the name of the server on your local network" \
"About" "Informations about this project and your system" \
$config$configOption 3>&1 1>&2 2>&3) ;do
	case $CHOICE in
		"Install apps") apps_menus install;;
		"Update") apps_menus update;;
		"Remove apps") apps_menus remove;;
		"Apps Service Manager") . sysutils/service.sh;;
		"Network app access") network_access;;
		"Hostname") change_hostname;;
		"About") whiptail --title "DPlatform - About" --yesno "DPlatform - Deploy self-hosted apps easily
		https://github.com/DFabric/DPlatform-ShellCore

		- Domain/host name: `hostname`
		- Local IPv4: $LOCALIP
		- Public IPv4: $IPv4
		- IPv6: $IPv6
		Your OS: $PRETTY_NAME $(uname -m)

Copyright (c) 2015-2016 Julien Reichardt - MIT License (MIT)" 16 64 --yes-button "           Ok           " --no-button "";;
		$config) $config;;
	esac
done
