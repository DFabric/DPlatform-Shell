#!/bin/sh
# DeployPlaform - Deploy self-hosted apps efficiently

# This script is implemented as POSIX-compliant.
# It should work on sh, dash, bash, ksh, zsh on Debian, Ubuntu, CentOS
# and probably other distros of the same families, although no support is offered for them.

DIR=$(cd -P $(dirname $0) && pwd)
# Detect IP
IPv4=$(wget -qO- ipv4.icanhazip.com)
IPv6=$(ip addr show dev eth0 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | head -n 1)
# Set default IP to IPv4 unless IPv6 is available
[ $IPv6 = "" ] && IP=$IPv4 || IP=[$IPv6]
LOCALIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
DOMAIN=$(hostname)

# Detect package manager
if hash apt-get 2>/dev/null
	then PKG=deb
	install="debconf-apt-progress -- apt-get install -y"
elif hash rpm 2>/dev/null
	then PKG=rpm
	install="yum install --enablerepo=epel -y"
elif hash pacman 2>/dev/null
	then PKG=pkg
	install="pacman -S"
else
	PKG=unknown
fi

# Detect distribution
if grep 'Ubuntu' /etc/issue 2>/dev/null
	then DIST=ubuntu
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
	x86_64 | amd64) ARCH=amd64;;
	i*86) ARCH=86;;
	armv6) ARCH=armv6;;
	arm*) ARCH=arm;;
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
#whiptail --msgbox " Not available" 8 32; break;
# Applications installation menu
installation_menu() {
	if [ $1 = update ] || [ $1 = remove ]
	then
		# Reset previous apps_choice variable
		apps_choice=
		if [ $1 = update ]
			then apps_choice="DPlatform Update_DPlatform"
		fi

		# Read installed-apps to create entries
		while read app
		do
			apps_choice="$apps_choice $app $1_$app"
		done < installed-apps

		while whiptail --title "DPlatform - $1 menu" --menu "
		What application would you like to $1?" 24 64 14 $apps_choice 2> /tmp/temp
		do
			cd $DIR
			read CHOICE < /tmp/temp
			# Confirmation message
			whiptail --yesno "		$CHOICE will be $1d.
			Are you sure to want to continue?" 8 48
			case $? in
				1) ;; # Return to installation menu
				0) # Delete the app entry in installed-apps file and supervisor related files
				if [ $1 = remove ]
				then
					supervisorctl stop $CHOICE
					sed -i "/\b$CHOICE\b/d" installed-apps
					rm /etc/supervisor/conf.d/$CHOICE.conf
					rm /var/log/$CHOICE*
					supervisorctl reread
					supervisorctl update
				fi
				case $CHOICE in
					DPlatform) git pull;;
					Agar.ioClone) . apps/agar.io-clone.sh $1;;
					Ajenti) . apps/ajenti.sh $1;;
					WP-Calypso) . apps/calypso.sh $1;;
					Cuberite) . apps/cuberite $1;;
					Dillinger) . apps/dillinger.sh $1;;
					Docker) . sysutils/docker.sh $1;;
					EtherCalc) . apps/ethercalc.sh $1;;
					EtherDraw) . apps/etherdraw.sh $1;;
					Etherpad) . apps/etherpad.sh $1;;
					GitLab) . apps/gitlab.sh $1;;
					Gogs) . apps/gogs.sh $1;;
					Ghost) . apps/ghost.sh $1;;
					JitsiMeet) . apps/jitsi-meet.sh $1;;
					JSBin) . apps/jsbin.sh $1;;
					KeystoneJS) . apps/keystonejs.sh $1;;
					LetsChat) . apps/lets-chat.sh $1;;
					Linx) . apps/linx.sh $1;;
					Mailpile) . apps/mailpile.sh $1;;
					Mattermost) . apps/mattermost.sh $1;;
					Mattermost-GitLab) . apps/mattermost-gitlab.sh $1;;
					Meteor) . sysutils/meteor.sh $1;;
					Modoboa) . apps/modoboa.sh $1;;
					MongoDB) . sysutils/mongodb.sh $1;;
					Mumble) . apps/mumble.sh $1;;
					Node.js) . sysutils/nodejs.sh $1;;
					OpenVPN) . apps/openvpn.sh $1;;
					ReactionCommerce) . apps/reaction.sh $1;;
					RetroPie) . apps/retropie.sh $1;;
					Rocket.Chat) . apps/rocketchat.sh $1;;
					Seafile) . apps/seafile.sh $1;;
					StackEdit) . apps/stackedit.sh $1;;
					Stringer) . apps/stringer.sh $1;;
					Syncthing) . apps/syncthing.sh $1;;
					Shout) . apps/shout.sh $1;;
					Taiga.Io) . apps/taigaio.sh $1;;
					Taiga-Lets-Chat) . apps/taigaio.sh $1;;
					Wagtail) . apps/wagtail.sh $1;;
					Wekan) . apps/wekan.sh $1;;
					Wide) . apps/wide.sh $1;;
				esac;;
			esac
		done
	else
		while whiptail --title "DPlatform - Installation menu" --menu "
		What application would you like to deploy?" 24 96 14 \
		Agar.ioClone "Agar.io clone written with Socket.IO and HTML5 canvas" \
		Ajenti "Web admin panel" \
		Cuberite "A custom Minecraft compatible game server written in C++" \
		WP-Calypso "Reading, writing, and managing all of your WordPress sites" \
		Dillinger "The last Markdown editor, ever" \
		Docker "Open container engine platform for distributed application" \
		EtherCalc "Web spreadsheet, Node.js port of Multi-user SocialCalc" \
		EtherDraw "Collaborative real-time drawing, sketching & painting" \
		Etherpad "Real-time collaborative document editor" \
		GitLab "Open source Version Control to collaborate on code" \
		Gogs "Gogs(Go Git Service), a painless self-hosted Git Service" \
		Ghost "Simple and powerful blogging/publishing platform" \
		JitsiMeet "Secure, Simple and Scalable Video Conferences" \
		JSBin "Collaborative JavaScript Debugging App" \
		KeystoneJS "Node.js CMS & Web Application Platform" \
		Laverna "Note taking application with Mardown editor and encryption" \
		LetsChat "Self-hosted chat app for small teams" \
		Linx "Self-hosted file/code/media sharing website" \
		Mailpile "Modern, fast email client with user-friendly privacy features" \
		Mattermost "Mattermost is an open source, on-prem Slack-alternative" \
		Mattermost-GitLab "GitLab Integration Service for Mattermost" \
		Meteor "The JavaScript App Platform" \
		Modoboa "Mail hosting made simple" \
		MongoDB "The next-generation database" \
		Mumble "Voicechat utility" \
		NodeBB "Node.js based community forum built for the modern web" \
		Node.js "Install Node.js using nvm" \
		OpenVPN "Open source secure tunneling VPN daemon" \
		ReactionCommerce "Modern reactive, real-time event driven ecommerce platform." \
		RetroPie "Setup Raspberry PI with RetroArch emulator and various cores" \
		Rocket.Chat "The Ultimate Open Source WebChat Platform" \
		Seafile "Cloud storage with file encryption and group sharing" \
		Shout "The self-hosted web IRC client" \
		StackEdit "In-browser markdown editor" \
		Stringer "A self-hosted, anti-social RSS reader" \
		Syncthing "Open Source Continuous File Synchronization" \
		Torrent "Deluge and Transmission torrent web interface" \
		Taiga.Io "Agile, Free and Open Source Project Management Platform" \
		Wagtail "Django CMS focused on flexibility and user experience" \
		Taiga-LetsChat "Taiga contrib plugin for Let's Chat integration" \
		Wekan "Collaborative Trello-like kanban board application" \
		Wide "Web-based IDE for Teams using Go(lang)" \
		2> /tmp/temp
		do
			cd $DIR
			read CHOICE < /tmp/temp
			# Confirmation message
			whiptail --yesno "		$CHOICE will be installed.
			Are you sure to want to continue?" 8 48
			case $? in
				1) ;; # Return to installation menu
				0) echo $CHOICE >> installed-apps
				case $CHOICE in
					Agar.ioClone) . apps/agar.io-clone.sh;;
					Ajenti) . apps/ajenti.sh;;
					WP-Calypso) . apps/calypso.sh;;
					Cuberite) . apps/cuberite.sh;;
					Dillinger) . apps/dillinger.sh;;
					Docker) . sysutils/docker.sh;;
					EtherCalc) . apps/ethercalc.sh;;
					EtherDraw) . apps/etherdraw.sh;;
					Etherpad) . apps/etherpad.sh;;
					GitLab) . apps/gitlab.sh;;
					Gogs) . apps/gogs.sh;;
					Ghost) . apps/ghost.sh;;
					JitsiMeet) . apps/jitsi-meet.sh;;
					JSBin) . apps/jsbin.sh;;
					KeystoneJS) . apps/keystonejs.sh;;
					LetsChat) . apps/lets-chat.sh;;
					Linx) . apps/linx.sh;;
					Mailpile) . apps/mailpile.sh;;
					Mattermost) . apps/mattermost.sh;;
					Mattermost-GitLab) . apps/mattermost-gitlab.sh;;
					Meteor) . sysutils/meteor.sh;;
					Modoboa) . apps/modoboa.sh;;
					MongoDB) . sysutils/mongodb.sh;;
					Mumble) . apps/mumble.sh;;
					Node.js) . sysutils/nodejs.sh;;
					OpenVPN) . apps/openvpn.sh;;
					ReactionCommerce) . apps/reaction.sh;;
					RetroPie) . apps/retropie.sh;;
					Rocket.Chat) . apps/rocketchat.sh;;
					Seafile) . apps/seafile.sh;;
					StackEdit) . apps/stackedit.sh;;
					Stringer) . apps/stringer.sh;;
					Syncthing) . apps/syncthing.sh;;
					Shout) . apps/shout.sh;;
					Taiga.Io) . apps/taigaio.sh;;
					Taiga-Lets-Chat) . apps/taigaio.sh;;
					Wagtail) . apps/wagtail.sh;;
					Wekan) . apps/wekan.sh;;
					Wide) . apps/wide.sh;;
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
while whiptail --title "DPlatform - Main menu" --menu "Select with Arrows <-v^-> and Tab <=>. Confirm with Enter <-'" 16 96 8 \
"Install apps" "Install new applications" \
"Update" "Update applications and DPlatform" \
"Remove apps" "Uninstall applications" \
"Apps Service Manager" "Start/Stop and auto start services at startup" \
"Domain name" "Set a domain name to use a name instead of the computer's IP address" \
"About" "Informations about this project and your system" \ $config${configOption}
2> /tmp/temp
do
	cd $DIR
	read CHOICE < /tmp/temp
	case $CHOICE in
		$config) $config;;
		"Install apps") installation_menu install;;
		Update) installation_menu update;;
		"Remove apps") installation_menu remove;;
		"Apps Service Manager") . sysutils/supervisor.sh;;
		"Domain name") . sysutils/domain-name.sh;;
		About) whiptail --title "DPlatform - About" --msgbox "DPlatform - Deploy self-hosted apps efficiently
		https://github.com/j8r/DPlatform

		- Your host/domain name: $DOMAIN
		- Your public IPv4: $IPv4
		- Your local IP: $LOCALIP
		- Your IPv6: $IPv6
		Your OS: $ARCH arch $PKG based $(cat /etc/issue)
		Copyright (c) 2015 Julien Reichardt - MIT License (MIT)" 16 68;;
	esac
done
