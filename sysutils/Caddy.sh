#!/bin/sh

# https://github.com/mholt/caddy/tree/master/dist/init/linux-systemd

if [ "$1" = update ] ;then
  # Check Caddy version
  caddy_ver=$(caddy -version)
  # Keep the version number
  caddy_ver=${caddy_ver#Caddy *}

  # Get the latest Caddy release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mholt/caddy/releases/latest)
  # Only keep the version number in the url
  ver=${ver#*v}

  [ $caddy_ver = $ver ] && whiptail --msgbox "You have the $ver version of Caddy, the latest avalaible!" 8 48
  [ $caddy_ver != $ver ] && { whiptail --yesno "You have Caddy $caddy_ver, the latest is $ver. Upgrading Caddy...
  Would you like also use the newest Caddy service?" 10 64; [ $? = 0 ] && rm -rf /etc/systemd/system/Caddy.service; } && rm -rf /usr/bin/caddy || exit
fi

[ "$1" = remove ] && [ "$2" = "" ] && { sh sysutils/service.sh remove Caddy; rm -rf /usr/bin/caddy; rm -rf /etc/caddy/Caddyfile; whiptail --msgbox "Caddy removed!" 8 32; exit; }

# Install Caddy if not installed
if ! hash caddy 2>/dev/null ;then
  # Install unzip if not installed
  hash unzip 2>/dev/null || $install unzip
  arch=amd64
  [ $ARCHf = arm ] && arch=arm
  [ $ARCHf = 86 ] && arch=386

  groupadd -g 33 www-data
  useradd \
    -g www-data --no-user-group \
    --home-dir /var/www --no-create-home \
    --shell /usr/sbin/nologin \
    --system --uid 33 www-data

  mkdir /etc/caddy
  chown -R root:www-data /etc/caddy
  mkdir /etc/ssl/caddy
  chown -R www-data:root /etc/ssl/caddy
  chmod 0770 /etc/ssl/caddy

  # Create a temp directrory
  mkdir /tmp/caddy

  # Download  Caddy
  wget "https://caddyserver.com/download/build?os=linux&arch=$arch&features=" -O /tmp/caddy.tar.gz

  # Extract the downloaded archive and remove it
  extract "/tmp/caddy.tar.gz" "xzf - -C /tmp/caddy" "Extracting the files from the archive..."
  rm /tmp/caddy.tar.gz

  # Put the caddy binary to its directrory
  mv /tmp/caddy/caddy /usr/bin

  # Put the caddy SystemD service to its directrory
  mv /tmp/caddy/init/linux-systemd/caddy.service /etc/systemd/system

  rm -r /tmp/caddy

  # Create a caddy directory and create the Caddyfile configuration file
  mkdir -p /etc/caddy
  touch /etc/caddy/Caddyfile

  # Start CAddy and enable the auto-start it at boot
  systemctl start caddy
  systemctl enable caddy

  [ $1 = update ] && whiptail --msgbox "Caddy updated!" 8 32

  grep Caddy dp.cfg || whiptail --msgbox "  Caddy installed!
  Caddy run as 'www-data' user and group

  You can modify the Caddy configuration files:
  Caddyfile configuration: '/etc/caddy/Caddyfile'
  Service configuration: '/etc/systemd/system/caddy.service'" 12 64 && echo Caddy >> dp.cfg
else
  echo "Caddy is already installed"
fi

if grep "$1" /etc/caddy/Caddyfile ;then
  # Remove the app entry from the Caddyfile
  sed "/$1/,/}
/d" /etc/caddy/Caddyfile

  # Restart Caddy to apply the changes
  systemctl restart caddy
fi
