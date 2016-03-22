#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Seafile && sh sysutils/services.sh remove Seahub  && (rm -rf ~/haiwen; rm -rf ~/seafile-server*) && whiptail --msgbox "Seafile removed!" 8 32 && break

cd
whiptail --title Seafile --menu "	What data base would you like to deploy with Seafile?

SQLite fit in Home/Personal Environment
MariaDB/Nginx is recommended in Production/Enterprise Environment

If you don't know, the first answer should fit you" 16 80 2 \
"Deploy Seafile with SQLite" "Light, powerfull, simpler" \
"Deploy Seafile with MariaDB" "Advanced, secure, heavier" \
2> /tmp/temp
read CHOICE < /tmp/temp
case $CHOICE in

	# http://manual.seafile.com/deploy/using_sqlite.html
	"Deploy Seafile with SQLite")
	if [ $ARCH = amd64 ]
		then wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.0.4_x86-64.tar.gz
	elif [ $ARCH = 86 ]
		then wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.0.4_i386.tar.gz
	elif [ $ARCH = arm ]
	then
		# Get the latest Seafile release
		ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile-rpi/releases/latest)
		# Only keep the version number in the url
		ver=$(echo $ver | awk '{ver=substr($0, 53); print ver;}')
		# One of this 3 link works
		wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_stable_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v$ver/seafile-server_beta_${ver}_pi.tar.gz | wget https://github.com/haiwen/seafile-rpi/releases/download/v5.0.5/seafile-server_stable_jobenvil_5.0.5_pi.tar.gz
	fi
	mkdir haiwen
	mv seafile-server_* haiwen
	cd haiwen

	# after moving seafile-server_* to this directory
	tar -xzf seafile-server_*
	mkdir installed
	mv seafile-server_* installed

	# Prerequisites
	$install python2.7 libpython2.7 python-setuptools python-imaging python-ldap sqlite3

	cd seafile-server-*
	#run the setup script & answer prompted questions
	./setup-seafile.sh

	# Create SystemD service and run the server
	cat > /etc/systemd/system/seafile.service <<EOF
[Unit]
Description=Seafile Server
After=network.target sqlite.service
[Service]
Type=oneshot
ExecStart=$HOME/seafile/seafile-server-latest/seafile.sh start
ExecStop=$HOME/seafile/seafile-server-latest/seafile.sh stop
User=$USER
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	systemctl enable seafile
	cat > /etc/systemd/system/seahub.service <<EOF
[Unit]
Description=Seafile Seahub
After=network.target seafile.service
[Service]
Type=oneshot
ExecStart=$HOME/seafile/seafile-server-latest/seahub.sh start-fastcgi 8000
ExecStop=$HOME/seafile/seafile-server-latest/seahub.sh stop
User=$USER
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	systemctl enable seahub
	systemctl start seahub;;
	# https://github.com/SeafileDE/seafile-server-installer
	"Deploy Seafile with MariaDB")
	$install lsb-release
	# Only Debian based OS are supported
	[ $PKG != deb ] && whiptail --msgbox "Your package manager ($PKG) is not supported, only Debian based OS using deb are supported" 8 48 && exit 1
	if [ $ARCH = arm ]
		then dist=seafile-ce_ubuntu-trusty-arm
	elif [ $DIST = ubuntu ] && [ $ARCH = x86_64 ]
		then dist=seafile-ce_ubuntu-trusty-amd64
	else
		dist=seafile_v5_debian
	fi
	wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/$dist
	bash $dist
esac

whiptail --msgbox "Seafile successfully installed!
Open http://$IP:<port> in your browser

Default port: 8000. To change it, for example to 8001
You can modify SERVICE_URL via web UI in System Admin->Settings
By default, you should open 2 ports, 8000 and 8082, in your firewall settings.
If you run Seafile behind Nginx/Apache with HTTPS, you only need port 443" 14 80
