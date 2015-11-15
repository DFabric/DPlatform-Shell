#!/bin/sh
DIR=$(cd -P $(dirname $0) && pwd)

# Detect package manager
if hash apt-get 2>/dev/null
	then PKG=deb
	install="apt-get install -y"
elif hash rpm 2>/dev/null
	then PKG=rpm
	install="yum install --enablerepo=epel -y"
elif hash pacman 2>/dev/null
	then PKG=pkg
	install="pacman -S"
fi
# Detect distro
if grep 'Ubuntu' /etc/issue 2>/dev/null
	then DIST=ubuntu
fi
# Detect arch
ARCH=$(uname -m)
if echo $ARCH | grep x86_64
	then ARCH=amd64
elif echo $ARCH | grep 86
	then ARCH=86
elif echo $ARCH | grep arm
	then ARCH=arm
fi

clear
whiptail --title DPlatform --msgbox "
DPlatform - Deploy self-hosted apps efficiently

https://github.com/j8r/DPlatform



Copyright (c) 2015 Julien Reichardt - MIT License (MIT)" 16 64
trap 'rm -f choice$$' 0 1 2 5 15 EXIT
while whiptail --title "DPlatform - Main menu" --menu "
				What service would you like to deploy?" 24 96 12 \
	"Agar.io Clone" "Agar.io clone written with Socket.IO and HTML5 canvas" \
	"Ajenti" "Web admin panel" \
	"Docker" "Open container engine platform for distributed application" \
	"EtherCalc" "Web spreadsheet, Node.js port of Multi-user SocialCalc" \
	"Etherpad" "Real-time collaborative document editor" \
	"GitLab" "Open source Version Control to collaborate on code" \
	"Gogs" "Gogs(Go Git Service), a painless self-hosted Git Service" \
	"Ghost" "Simple and powerful blogging/publishing platform" \
	"KeystoneJS" "Node.js CMS & Web Application Platform" \
	"Let's Chat" "Self-hosted chat app for small teams" \
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
	"Taiga.Io" "Agile, Free and Open Source Project Management Platform" \
	"Wagtail" "Django CMS focused on flexibility and user experience" \
	"Taiga-LetsChat" "Taiga contrib plugin for Let's Chat integration" \
	"Wekan" "Collaborative Trello-like kanban board application" \
	"Wide" "Web-based IDE for Teams using Go(lang)" \
	"update" "Update Confinux" \
	2> choice$$
	do cd $DIR
	read CHOICE < choice$$
	# Confirmation dialog
	whiptail --yesno "		$CHOICE will be installed.
	Do you want to continue?" 8 48
	case $? in
		1) ;; # Return to main menu
		0) case $CHOICE in
		"Agar.io Clone") . apps/agar.io-clone.sh;;
		Ajenti) . apps/ajenti.sh;;
		Docker) . sysutils/docker.sh;;
		Etherpad) . apps/etherpad.sh;;
		EtherCalc) . apps/ethercalc.sh;;
		GitLab) . apps/gitlab.sh;;
		Gogs) . apps/gogs.sh;;
		Ghost) . apps/ghost.sh;;
		KeystoneJS) . apps/keystonejs.sh;;
		"Let's Chat") . apps/lets-chat.sh;;
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
		update) if hash git 2>/dev/null
		then git pull
		else
			rm -r *
			wget https://github.com/j8r/DPlatform/archive/master.zip
			unzip master.zip
			cp -r DPlatform-master/* .
			rm -r *master*
		fi
		whiptail --msgbox "DPlatform is successfully updated" 8 60;;
		esac;;
	esac
done
