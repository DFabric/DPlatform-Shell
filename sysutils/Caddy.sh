#!/bin/sh

if [ "$1" = remove ] && [ "$2" = "" ] ;then
  whiptail --msgbox "Not availabe yet!" 8 32
  break
fi
if [ "$1" = update ] ;then
  # Check Caddy version
  caddy_ver=$(caddy -version)
  # Keep the version number
  caddy_ver=${caddy_ver#Caddy *}

  # Get the latest Caddy release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mholt/caddy/releases/latest)
  # Only keep the version number in the url
  ver=${ver#*v}

  [ $caddy_ver = $ver ] && whitpail --msgbox "You have the $ver version of Caddy, the latest avalaible!" 8 48
  [ $caddy_ver != $ver ] && echo "You have Caddy $caddy_ver, the latest is $ver. Upgrading Caddy..." || exit
fi

# Install Caddy if not installed
if ! hash caddy 2>/dev/null ;then
  # Install unzip if not installed
  hash unzip 2>/dev/null || $install unzip
  arch=amd64
  [ $ARCHf = arm ] && arch=arm
  [ $ARCHf = 86 ] && arch=386

  # Download  Caddy
  wget https://caddyserver.com/download/build?os=linux&arch=$arch&features= -O caddy.tar.gz

  # Extract the downloaded archive and remove it
  mkdir /tmp/caddy
  extract caddy.tar.gz "xzf -C /tmp/caddy" "Extracting the files from the archive..."
  rm caddy.tar.gz

  # Put the caddy binary to its directrory
  mv /tmp/caddy/caddy /usr/bin

  # Put the caddy SystemD service to its directrory
  mv /tmp/caddy/init/linux-systemd/caddy@.service /etc/systemd/system/caddy.service

  rm -r /tmp/caddy
  # Remove Group=http
  sed -i "/Group=http/d" /etc/systemd/system/caddy.service

  # Create a caddy directory and create the Caddyfile configuration file
  mkdir -p /etc/caddy
  touch /etc/caddy/Caddyfile

  # Start CAddy and enable the auto-start it at boot
  systemctl start caddy
  systemctl enable caddy

  [ $1 = update ] && whiptail --msgbox "Caddy updated!" 8 32

  grep Caddy dp.cfg || echo "Caddy installed!" && echo Caddy >> dp.cfg
fi

if grep "$1" /etc/caddy/Caddyfile ;then
  # Remove the app entry from the Caddyfile
  sed "/$1/,/}
/d" /etc/caddy/Caddyfile

  # Restart Caddy to apply the changes
  systemctl restart caddy
fi
