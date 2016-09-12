#!/bin/sh
[ $PKG = rpm ] && { whiptail --msgbox "Your $PKG isn't supported yet" 8 32; exit; }
[ $1 = update ] && [ $PKG = deb ] && { apt-get update; $install mopidy; pip install --upgrade -y Mopidy-Mopify; whiptail --msgbox "Mopidy updated!" 8 32; break; }
[ $1 = remove ] && { $remove mopidy; pip uninstall -y Mopidy-Mopify; whiptail --msgbox "Mopidy  updated!" 8 32; break; }

# Define ports
MPDport=$(whiptail --title "MPD server port" --inputbox "Set a port number for the MPD server" 8 48 "6600" 3>&1 1>&2 2>&3)

port=$(whiptail --title "Mopify web client port" --inputbox "Set a port number for Mopify web client" 8 48 "6680" 3>&1 1>&2 2>&3)

if [ $PKG = deb ] ;then
  # Add the archive’s GPG key
  wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
  case "$DIST$DIST_VER" in
    # For Debian wheezy or Ubuntu 12.04 LTS
    debian7*|*ubuntu*12.04*) wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/wheezy.list;;
    # For any newer Debian/Ubuntu distro
    *) wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/jessie.list;;
  esac
  # Install Mopidy and all dependencies
  apt-get update
fi
[ $PKG = rpm ]; whiptail --yesno "Your have $DIST. $PGK based OS aren't supported yet." 8 32
[ $PKG != rpm ] || break
$install mopidy

# Install Mopify, a web client for Mopidy
pip install Mopidy-Mopify

[ $IP = $LOCALIP ] && access=$IP || access=::
cat > /etc/mopidy/mopidy.conf <<EOF
[http]
hostname = $access
port = $port
[mpd]
hostname = $access
port = $MPDport
max_connections = 40
connection_timeout = 120
EOF
# Start the service and enable it to start up on boot
systemctl enable mopidy
systemctl restart mopidy

whiptail --msgbox "Modipy installed!

The MPD server port is $MPDport

Open http://$URL:$port in your browser" 12 64
