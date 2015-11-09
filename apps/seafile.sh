#!/bin/sh

trap 'rm -f choice$$' 0 1 2 5 15 EXIT
while whiptail --title Seafile --menu "What data base would you like to deploy with Seafile?

SQLite is good in Home/Personal Environment, while MariaDB/Nginx is recommended in Production/Enterprise Environment

If you don't know, the first answer should fit you" 16 64 2 \
	 "Deploy Seafile with SQLite" "Light, powerfull, simpler" \
	 "Deploy Seafile with MariaDB" "Advanced features, heavier" \
	 2> choice$$
	 read CHOICE < choice$$
	 case $CHOICE in
		 "Deploy Seafile with SQLite") seafile_sqlite();;
		 "Deploy Seafile with MariaDB") seafile_mariadb();;
   esac
done

# https://github.com/SeafileDE/seafile-server-installer
seafile_mariadb() {
apt-get install lsb-release -y
cd /root
# Only Debian based OS are supported
if test "$PKG" != deb
  then whiptail --msgbox "Your package manager is not supported, only Debian based OS using deb are supported" 8 48
  break
fi
if ARCH=arm
  then dist=seafile-ce_ubuntu-trusty-arm
elif DIST=ubuntu && ARCH=x86_64
  then dist=seafile-ce_ubuntu-trusty-amd64
else
  dist=seafile_debian
fi

wget --no-check-certificate https://raw.githubusercontent.com/SeafileDE/seafile-server-installer/master/$dist
bash $dist
}

# http://manual.seafile.com/deploy/using_sqlite.html
seafile_sqlite() {
if ARCH=amd64
  then wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_5.0.0_x86-64-beta.tar.gz
elif ARCH=86
  then wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_4.4.5_i386.tar.gz

elif ARCH=arm
  then # Get the latest Seafile release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/haiwen/seafile-rpi/releases/latest)
  # Only keep the version number in the url
  ver=$(echo $ver | awk '{ver=substr($0, 53); print ver;}')
  # One of this 3 link works
  wget https://github.com/haiwen/seafile-rpi/releases/download/$ver/seafile-server_'$ver'_pi.tar.gz
  wget https://github.com/haiwen/seafile-rpi/releases/download/$ver/seafile-server_stable_'$ver'_pi.tar.gz
  wget https://github.com/haiwen/seafile-rpi/releases/download/$ver/seafile-server_beta_'$ver'_pi.tar.gz
fi
mkdir haiwen
mv seafile-server_* haiwen
cd haiwen
# after moving seafile-server_* to this directory
tar -xzf seafile-server_*
mkdir installed
mv seafile-server_* installed

# Prerequisites
apt-get update
apt-get install python2.7 libpython2.7 python-setuptools python-imaging sqlite3

cd seafile-server-*
./setup-seafile.sh  #run the setup script & answer prompted questions
}
whiptail --msgbox "Seafile successfully installed!

Open http://your_hostname.com:8000 in your browser
You should open TCP port 8082 in your firewall settings.

Start Seafile and Seahub:
./seafile.sh start && ./seahub.sh start" 16 60
break
