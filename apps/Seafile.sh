#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Seafile; sh sysutils/service.sh remove Seahub; rm -rf /var/www/seafile; userdel -f seafile; whiptail --msgbox "Seafile removed." 8 32; break; }

db_choice=$(whiptail --title Seafile --menu "	What database would you like to use with Seafile?

SQLite fit in Home/Personal Environment
MariaDB/Nginx is recommended in Production/Enterprise Environment

If you don't know, the first answer should fit you" 16 80 2 \
"SQLite" "Light, powerfull, simple" \
"MariaDB" "Advanced, secure, heavier" \
3>&1 1>&2 2>&3)
case $db_choice in

	# https://manual.seafile.com/deploy/using_sqlite.html
	"SQLite")
	# Defining the ports
	webui_port=$(whiptail --title "Seahub WebUI port" --inputbox "Set a port number for the Seahub WebUI" 8 48 "8001" 3>&1 1>&2 2>&3)

	fileserver_port=$(whiptail --title "Seafile fileserver port" --inputbox "Set a port number for the Seafile fileserver" 8 48 "8082" 3>&1 1>&2 2>&3)

	# Create a seafile user
	useradd -rU seafile

	# Go to its directory
	mkdir -p /var/www/seafile
	cd /var/www/seafile

	if [ $ARCHf = arm ]; then
		# Get the latest Seafile release
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile-rpi/releases/latest)
		# Only keep the version number in the url
		ver=${ver#*v}
		# One of this 3 link works
		wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_stable_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_beta_${ver}_pi.tar.gz
	else
		# Get the latest Seafile release
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile/releases/latest)
		# Only keep the version number in the url
		ver=${ver#*v}
		ver=${ver%-server}

		[ $ARCH = amd64 ] && url=https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_${ver}_x86-64.tar.gz
		[ $ARCH = 86 ] && url=https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_${ver}_i386.tar.gz

		# Download the arcive
		download $url "Downloading the Seafile $ver archive..."
	fi

	# Extract the downloaded archive and remove it
	extract seafile-server_* "xzf -" "Extracting the files from the archive..."
	rm seafile-server_*

	# Prerequisites
	$install python2.7 libpython2.7 python-setuptools python-imaging python-ldap sqlite3 sudo

	cd seafile-server-$ver
	#run the setup script & answer prompted questions
	./setup-seafile.sh auto -n $(hostname) -i $IP -p $fileserver_port

	# Change the port in the ccnet.conf
	sed -i "s/8000/$webui_port/g" /var/www/seafile/conf/ccnet.conf

	# Change the owner from root to seafile
	chown -R seafile:seafile /var/www/seafile
	# Create systemd service and run the server
	cat > /etc/systemd/system/seafile.service <<EOF
[Unit]
Description=Seafile Server
Wants=sqlite.service
After=network.target sqlite.service
[Service]
Type=oneshot
ExecStart=/var/www/seafile/seafile-server-$ver/seafile.sh start
ExecStop=/var/www/seafile/seafile-server-$ver/seafile.sh stop
User=seafile
Group=seafile
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	# Start the service and enable it to start at boot
	systemctl start seafile
	systemctl enable seafile
	/var/www/seafile/seafile-server-$ver/seahub.sh start $port
	/var/www/seafile/seafile-server-$ver/seahub.sh stop
	cat > /etc/systemd/system/seahub.service <<EOF
[Unit]
Description=Seafile Seahub
Wants=seafile.service
After=network.target seafile.service
[Service]
Type=oneshot
ExecStart=/var/www/seafile/seafile-server-$ver/seahub.sh start $webui_port
ExecStop=/var/www/seafile/seafile-server-$ver/seahub.sh stop
User=seafile
Group=seafile
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	# Start the service and enable it to start at boot
	systemctl start seahub
	systemctl enable seahub

	whiptail --msgbox "	Seafile installed!
	Open http://$URL:$webui_port in your browser
	By default, you should open 2 ports, $webui_port and $fileserver_port
	in your firewall settings." 10 64;;
	# https://github.com/haiwen/seafile-server-installer
	"MariaDB")
	$install lsb-release
	if [ $ARCHf = arm ] ;then
		download https://raw.githubusercontent.com/haiwen/seafile-server-installer/master/community-edition/seafile-ce_ubuntu-trusty-arm
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile-rpi/releases/latest)
		# Only keep the version number in the url
		ver=${ver#*v}
	elif [ $DIST$DIST_VER = ubuntu14.04 ] && [ $ARCH = amd64 ] ;then
		download https://raw.githubusercontent.com/haiwen/seafile-server-installer/master/community-edition/seafile-ce_ubuntu-trusty-amd64
	elif [ $DIST$DIST_VER = ubuntu16.04 ] && [ $ARCH = amd64 ] ;then
		download https://raw.githubusercontent.com/haiwen/seafile-server-installer/master/seafile_ubuntu
	elif [ $ARCHf = amd64 ] ;then
		[ $PKG = deb ] && download https://raw.githubusercontent.com/haiwen/seafile-server-installer/master/seafile_debian
		[ $PKG = rpm ] && download https://raw.githubusercontent.com/haiwen/seafile-server-installer/master/seafile_centos
	else
		whiptail --msgbox "Your system isn't supported yet" 8 48; break
	fi
	if [ $ARCH = amd64 ] ;then
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile/releases/latest)
		# Only keep the version number in the url
		ver=${ver#*v}
		ver=${ver%-server}
	fi
	bash seafile* $ver;;
esac
