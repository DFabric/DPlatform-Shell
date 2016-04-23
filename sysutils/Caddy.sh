#!/bin/sh

if [ "$1" = remove ] && [ "$2" = "" ]
then
  whiptail --msgbox "Not availabe yet!" 8 32
  break
fi
if [ "$1" = update ]
then
  # Check Caddy version
  caddy_ver=$(caddy -version)
  # Keep the version number
  caddy_ver=${caddy_ver#Caddy *}

  # Get the latest Caddy release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mholt/caddy/releases/latest)
  # Only keep the version number in the url
  ver=${ver#*v}

  [ $caddy_ver = $ver ] && whiptail --msgbox "You have the $ver version of Caddy, the latest avalaible!" 8 48
  [ $caddy_ver != $ver ] && echo "You have Caddy $caddy_ver, the latest is $ver. Upgrading Caddy..." || break
fi

# Install Caddy if not installed
if ! hash caddy 2>/dev/null
then
  # Install unzip if not installed
  hash unzip 2>/dev/null || $install unzip

  [ $ARCH = 86 ] && ARCH=386
  cd /usr/bin
  # Download and extract Caddy
  curl https://caddyserver.com/download/build?os=linux&arch=$ARCH&features= -o caddy.tar.gz
  # Extract the downloaded archive and remove it
  (pv -n caddy.tar.gz | tar xzf -) 2>&1 | whiptail --gauge "Extracting the files from the downloaded archive..." 6 64 0

  # Download the caddy SystemD service to its directrory
  curl https://raw.githubusercontent.com/mholt/caddy/master/dist/init/linux-systemd/caddy%40.service -o /etc/systemd/system/caddy.service
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

if grep "$1" /etc/caddy/Caddyfile
then
  # Remove the app entry from the Caddyfile
  sed "/$1/,/}
/d" /etc/caddy/Caddyfile

  # Restart Caddy to apply the changes
  systemctl restart caddy

elif [ "$1" != "" ]
then
  # Add this app entry ine the Caddyfile to proxy it
  cat >> /etc/caddy/Caddyfile <<EOF
$IP {
    proxy / localhost:$1
}

EOF
  # Restart Caddy to apply the changes
  systemctl restart caddy
fi
