#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Seafile && sh sysutils/services.sh remove Seahub  && (rm -rf ~/haiwen; rm -rf ~/seafile-server*) && whiptail --msgbox "Seafile removed!" 8 32 && break

DB_CHOICE=$(hiptail --title Seafile --menu "	What data base would you like to deploy with Seafile?

SQLite fit in Home/Personal Environment
MariaDB/Nginx is recommended in Production/Enterprise Environment

If you don't know, the first answer should fit you" 16 80 2 \
"Deploy Seafile with SQLite" "Light, powerfull, simpler" \
"Deploy Seafile with MariaDB" "Advanced, secure, heavier" \
3>&1 1>&2 2>&3)
case $DB_CHOICE in

	# http://manual.seafile.com/deploy/using_sqlite.html
	"Deploy Seafile with SQLite")
	# Define port
	port=$(whiptail --title "Seafile port" --inputbox "Set a port number for Seafile" 8 48 "8001" 3>&1 1>&2 2>&3)

	# Create a seafile user
	useradd -m seafile

	# Go to its directory
	cd /home/seafile

	[ $ARCH = amd64 ] && url=https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.1.1_x86-64.tar.gz
	[ $ARCH = 86 ] && url=https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.1.1_i386.tar.gz
	if [ $ARCH = arm ]; then
		# Get the latest Seafile release
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile-rpi/releases/latest)
		# Only keep the version number in the url
		ver=${ver#*v}
		# One of this 3 link works
		wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_stable_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_beta_${ver}_pi.tar.gz
	else
		# Download the arcive
		wget $url 2>&1 | \
		stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --gauge "Downloading the archive..." 6 64 0
	fi

	# Extract the downloaded archive and remove it
	(pv -n seafile-server_* | tar xzf -) 2>&1 | whiptail --gauge "Extracting the files from the archive..." 6 64 0
	rm seafile-server_*

	# Prerequisites
	$install python2.7 libpython2.7 python-setuptools python-imaging python-ldap sqlite3

	cd seafile-server-*
	#run the setup script & answer prompted questions
	sudo -u seafile ./setup-seafile.sh

	# Change the port in the ccnet.conf
	sed -i "s/8000/$port/g" /home/seafile/conf/ccnet.conf

	# Change the owner from root to seafile
	chown -R seafile:seafile /home/seafile
	# Create SystemD service and run the server
	cat > /etc/systemd/system/seafile.service <<EOF
[Unit]
Description=Seafile Server
Wants=sqlite.service
After=network.target sqlite.service
[Service]
Type=oneshot
ExecStart=/home/seafile/seafile-server-latest/seafile.sh start
ExecStop=/home/seafile/seafile-server-latest/seafile.sh stop
User=seafile
Group=seafile
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	# Start the service and enable it to start on boot
	systemctl start seafile
	systemctl enable seafile
	./home/seafile/seafile-server-latest/seahub.sh start $port
	./home/seafile/seafile-server-latest/seahub.sh stop
	cat > /etc/systemd/system/seahub.service <<EOF
[Unit]
Description=Seafile Seahub
Wants=seafile.service
After=network.target seafile.service
[Service]
Type=oneshot
ExecStart=/home/seafile/seafile-server-latest/seahub.sh start $port
ExecStop=/home/seafile/seafile-server-latest/seahub.sh stop
User=seafile
Group=seafile
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	# Start the service and enable it to start on boot
	systemctl start seahub
	systemctl enable seahub

	whiptail --msgbox "	Seafile installed!
	Open http://$URL:$port in your browser

	By default, you should open 2 ports, $port and 8082, in your firewall settings." 12 72
	#	If you run Seafile behind Nginx with HTTPS, you only need port 443;;
	# https://github.com/SeafileDE/seafile-server-installer
	"Deploy Seafile with MariaDB")
	$install lsb-release
	if [ $ARCH = arm ] ;then
		wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/community-edition/seafile-ce_ubuntu-trusty-arm
	elif [ $DIST = Ubuntu ] && [ $ARCH = amd64 ]; then
		wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/community-edition/seafile-ce_ubuntu-trusty-amd64
	elif [ $ARCH = amd64 ] ;then
		[ $PKG = deb ] && wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/seafile_v5_debian
		[ $PKG = rpm ] && wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/seafile_v5_debian
	else
		whiptail --msgbox "Your system isn't supported yet" 8 48
		break
	fi
	bash seafile*
esac
