#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Seafile && sh sysutils/services.sh remove Seahub  && (rm -rf ~/haiwen; rm -rf ~/seafile-server*) && whiptail --msgbox "Seafile removed!" 8 32 && break

whiptail --title Seafile --menu "	What data base would you like to deploy with Seafile?

SQLite fit in Home/Personal Environment
MariaDB/Nginx is recommended in Production/Enterprise Environment

If you don't know, the first answer should fit you" 16 80 2 \
"Deploy Seafile with SQLite" "Light, powerfull, simpler" \
"Deploy Seafile with MariaDB" "Advanced, secure, heavier" \
2> /tmp/temp
read DB_CHOICE < /tmp/temp
case $DB_CHOICE in

	# http://manual.seafile.com/deploy/using_sqlite.html
	"Deploy Seafile with SQLite")
	# Define port
	whiptail --title "Seafile port" --clear --inputbox "Enter a port number for Seafile. default:[8001]" 8 32 2> /tmp/temp
	read port < /tmp/temp
	port=${port:-8001}

	# Create a seafile user
	useradd -m seafile
	cd /home/seafile

	if [ $ARCH = amd64 ]
		then wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.0.5_x86-64.tar.gz
	elif [ $ARCH = 86 ]
		then wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.0.5_i386.tar.gz
	elif [ $ARCH = arm ]
	then
		# Get the latest Seafile release
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile-rpi/releases/latest)
		# Only keep the version number in the url
		ver=$(echo $ver | awk '{ver=substr($0, 53); print ver;}')
		# One of this 3 link works
		wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_stable_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_beta_${ver}_pi.tar.gz
	fi

	# Extract the downloaded archive and delete it
	tar zxvf seafile-server_*
	rm seafile-server_*

	# Prerequisites
	$install python2.7 libpython2.7 python-setuptools python-imaging python-ldap sqlite3

	cd seafile-server-*
	#run the setup script & answer prompted questions
	sudo -u seafile ./setup-seafile.sh

	# Change the port in the ccnet.conf
	sed -i "s/8000/$port/g" /home/seafile/conf/ccnet.conf

	# Change the owner from root to seafile
	chown -R seafile /home/seafile
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
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	systemctl enable seafile
	systemctl start seafile
	/home/seafile/seafile-server-latest/seahub.sh start $port
	/home/seafile/seafile-server-latest/seahub.sh stop
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
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	systemctl enable seahub
	systemctl start seahub

	whiptail --msgbox "	Seafile installed!
	Open http://$IP:$port in your browser

	By default, you should open 2 ports, 8001 and 8082, in your firewall settings.
	If you run Seafile behind Nginx with HTTPS, you only need port 443" 12 72;;
	# https://github.com/SeafileDE/seafile-server-installer
	"Deploy Seafile with MariaDB")
	$install lsb-release
	# Only Debian based OS are supported
	[ $PKG != deb ] && whiptail --msgbox "Your package manager ($PKG) is not supported, only Debian based OS using deb are supported" 8 48 && exit 1
	if [ $ARCH = arm ]
		then dist=seafile-ce_ubuntu-trusty-arm
	elif [ $DIST = Ubuntu ] && [ $ARCH = amd64 ]
		then 		wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/seafile_v5_debianseafile-ce_ubuntu-trusty-amd64
	else
		wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/seafile_v5_debian

	fi
	bash $dist
esac
