#!/bin/sh
DIR=$(cd -P $(dirname $0) && pwd)
IP=$(wget -qO- ipv4.icanhazip.com)
LOCALIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
DOMAIN=$(hostname -f)
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
if [ $ARCH = *x86_64* ]
	then ARCH=amd64
elif [ $ARCH = *86* ]
	then ARCH=86
elif [ $ARCH = *arm* ]
	then ARCH=arm
fi

# Applications installation menu
installation_menu() {
	trap 'rm -f /tmp/choice' EXIT
	while whiptail --title "DPlatform - Installation menu" --menu "
	What application would you like to deploy?" 24 96 14 \
	"Agar.io Clone" "Agar.io clone written with Socket.IO and HTML5 canvas" \
	"Ajenti" "Web admin panel" \
	"(WordPress) Calypso" "Reading, writing, and managing all of your WordPress sites" \
	"Dillinger" "The last Markdown editor, ever" \
	"Docker" "Open container engine platform for distributed application" \
	"EtherCalc" "Web spreadsheet, Node.js port of Multi-user SocialCalc" \
	"Etherpad" "Real-time collaborative document editor" \
	"GitLab" "Open source Version Control to collaborate on code" \
	"Gogs" "Gogs(Go Git Service), a painless self-hosted Git Service" \
	"Ghost" "Simple and powerful blogging/publishing platform" \
	"JS Bin" "Collaborative JavaScript Debugging App" \
	"KeystoneJS" "Node.js CMS & Web Application Platform" \
	"Laverna" "Note taking application with Mardown editor and encryption" \
	"Let's Chat" "Self-hosted chat app for small teams" \
	"Linx" " Self-hosted file/code/media sharing website" \
	"Mailpile" "Modern, fast email client with user-friendly privacy features" \
	"Mattermost" "Mattermost is an open source, on-prem Slack-alternative" \
	"Mattermost-GitLab" "GitLab Integration Service for Mattermost" \
	"Modoboa" "Mail hosting made simple" \
	"Mumble" "Voicechat utility" \
	"NodeBB" "Node.js based community forum built for the modern web" \
	"Node.js" "Install Node.js using nvm" \
	"OpenVPN" "Open source secure tunneling VPN daemon" \
	"Rocket.Chat" "The Ultimate Open Source WebChat Platform" \
	"RetroPie" "Setup Raspberry PI with RetroArch emulator and various cores" \
	"Seafile" "Cloud storage with file encryption and group sharing" \
	"Shout" "The self-hosted web IRC client" \
	"Stringer" "A self-hosted, anti-social RSS reader" \
	"Syncthing" "Open Source Continuous File Synchronization" \
	"Torrent" "Deluge and Transmission torrent web interface" \
	"Taiga.Io" "Agile, Free and Open Source Project Management Platform" \
	"Wagtail" "Django CMS focused on flexibility and user experience" \
	"Taiga-LetsChat" "Taiga contrib plugin for Let's Chat integration" \
	"Wekan" "Collaborative Trello-like kanban board application" \
	"Wide" "Web-based IDE for Teams using Go(lang)" \
	2> /tmp/choice
	do
		cd $DIR
		read CHOICE < /tmp/choice
		# Confirmation dialog
		whiptail --yesno "		$CHOICE will be installed.
		Do you want to continue?" 8 48
		case $? in
			1) ;; # Return to installation menu
			0) echo $CHOICE #>> installed-apps
			case $CHOICE in
			"Agar.io Clone") . apps/agar.io-clone.sh;;
			Ajenti) . apps/ajenti.sh;;
			"(WordPress) Calypso") . apps/calypso.sh;;
			Dillinger) . apps/dillinger.sh;;
			Docker) . sysutils/docker.sh;;
			Etherpad) . apps/etherpad.sh;;
			EtherCalc) . apps/ethercalc.sh;;
			GitLab) . apps/gitlab.sh;;
			Gogs) . apps/gogs.sh;;
			Ghost) . apps/ghost.sh;;
			"JS Bin") . apps/jsbin.sh;;
			KeystoneJS) . apps/keystonejs.sh;;
			"Let's Chat") . apps/lets-chat.sh;;
			Linx) . apps/linx.sh;;
			Mailpile) . apps/mailpile.sh;;
			Mattermost) . apps/mattermost.sh;;
			Mattermost-GitLab) . apps/mattermost-gitlab.sh;;
			Modoboa) . apps/modoboa.sh;;
			Mumble) . apps/mumble.sh;;
			Node.js) . sysutils/nodejs.sh;;
			OpenVPN) . apps/openvpn.sh;;
			Rocket.Chat) . apps/rocketchat.sh;;
			RetroPie) . apps/retropie.sh;;
			Seafile) . apps/seafile.sh;;
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
}

# Main menu
trap 'rm -f /tmp/choice' EXIT
while whiptail --title "DPlatform - Main menu" --menu "	Select with Arrows <-v^-> and Tab <=>. Confirm with Enter <-'" 16 96 8 \
"Install apps" "Install new applications" \
"Update" "Update applications and DPlatform" \
"Remove apps" "Uninstall applications" \
"Service Manager" "Start/Stop, and set auto start/stop services at startup" \
"Domain name" "Set a domain name to use a name instead of the computer's IP address" \
"About" "Informations about this project and your system" \
2> /tmp/choice
do
	cd $DIR
	read CHOICE < /tmp/choice
	case $CHOICE in
		"Install apps") installation_menu;;
		Update) git pull
		whiptail --msgbox "	DPlatform updated. Applications update comming soon\!" 8 48;;
		"Remove apps") whiptail --msgbox "	Comming soon\!" 8 48;;
		"Service Manager") whiptail --msgbox "	Comming soon\!" 8 48;;
		"Domain name") . sysutils/domain-name.sh;;
		About) whiptail --title "DPlatform - About" --msgbox "DPlatform - Deploy self-hosted apps efficiently
		https://github.com/j8r/DPlatform

		=Your domain name: $DOMAIN
		-Your public IP: $IP
		Your local IP: $LOCALIP
		Your OS: $ARCH arch $PKG based $(cat /etc/issue)
		Copyright (c) 2015 Julien Reichardt - MIT License (MIT)" 16 68;;
	esac
done
