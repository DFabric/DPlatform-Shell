#!/bin/sh
[ $PKG != rpm ] && whiptail --msgbox "Your $PKG isn't supported yet" 8 32 && break
[ $1 = update ] && [ $PKG = deb ] && apt-get update && $install mopidy && whiptail --msgbox "Mopidy updated!" 8 32 && break
[ $1 = remove ] && $remove mopidy && whiptail --msgbox "Mopidy removed!" 8 32 && break

if [ $PKG = deb ]
then
  # Add the archive’s GPG key
  wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/jessie.list
  case "$DIST$DIST_VER" in
    # For Debian wheezy or Ubuntu 12.04 LTS
    debian7*|*ubuntu*12.04*) wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/wheezy.list;;
    # For any newer Debian/Ubuntu distro:
    *) wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/jessie.list;;
  esac
  # Install Mopidy and all dependencies:
  apt-get update
fi
$install mopidy

pip install mopidy-musicbox-webclient

# Define password and port
whiptail --title "Mopidy port" --clear --inputbox "Enter your Mopidy password. default:[]" 8 32 2> /tmp/temp
read port < /tmp/temp

whiptail --title "Mopidy port" --clear --inputbox "Enter your Mopidy port number. default:[6680]" 8 32 2> /tmp/temp
read port < /tmp/temp
port=${port:-6680}

cat >> ~/.config/mopidy/mopidy.conf <<EOF
[mpd]
hostname = ::
port = $port
password = $password
connection_timeout = 600
EOF
whiptail --msgbox "Modipy successfully installed!

The MPD server port is $port with $password in password
Open http://$IP:$port in your browser" 12 64
