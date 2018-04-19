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

  [ "$caddy_ver" = "$ver" ] && whiptail --msgbox "You have the $ver version of Caddy, the latest avalaible!" 8 48
  [ "$caddy_ver" != "$ver" ] && { whiptail --yesno "You have Caddy $caddy_ver, the latest is $ver.
  Would you like also use the newest Caddy service?" 10 64; [ $? = 0 ];  } || break
fi

[ "$1" = remove ] && [ "$2" = "" ] && { sh sysutils/service.sh remove Caddy; rm -f /usr/local/bin/caddy; rm -f /etc/caddy/Caddyfile; whiptail --msgbox "Caddy removed." 8 32; break; }

# Install Caddy if not installed
if [ "$1" = update ] || ! hash caddy 2>/dev/null ;then
  # Install unzip if not installed
  $install unzip
  arch=$ARCH
  [ $ARCH = armv7 ] && arch=arm7
  [ $ARCHf = 86 ] && arch=386

  groupadd -g 33 www-data
  useradd \
    -g www-data --no-user-group \
    --home-dir /var/www --no-create-home \
    --shell /usr/sbin/nologin \
    --system --uid 33 www-data

  # Create a caddy directory and create the Caddyfile configuration file
  mkdir -p /etc/caddy
  touch /etc/caddy/Caddyfile
  chown -R root:www-data /etc/caddy
  mkdir -p /etc/ssl/caddy
  chown -R www-data:root /etc/ssl/caddy
  chmod 0770 /etc/ssl/caddy

  # Create a temp directrory
  mkdir /tmp/caddy

  # Download Caddy
  download "https://caddyserver.com/download/linux/$arch?license=personal  -O /tmp/caddy.tar.gz" "Download the Caddy $ver archive..."

  # Extract the downloaded archive and remove it
  extract "/tmp/caddy.tar.gz" "xzf - -C /tmp/caddy" "Extracting the files from the archive..."
  rm /tmp/caddy.tar.gz

  # Put the caddy binary to its directrory
  mv /tmp/caddy/caddy /usr/local/bin
  chmod 755 /usr/local/bin/caddy

  # Give the caddy binary the ability to bind to privileged ports (e.g. 80, 443) as a non-root user
  setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

  # Put the caddy systemd service to its directrory
  mv /tmp/caddy/init/linux-systemd/caddy.service /etc/systemd/system

  # Set additional security directives. Only working with systemd v229
  if [ "$(systemctl --version | sed -n 's/systemd \([^ ]*\).*/\1/p')" -ge 229 ]; then
    # Uncommenting
    sed -i -e 's/;CapabilityBoundingSet/CapabilityBoundingSet/' -e 's/;AmbientCapabilities/AmbientCapabilities/' -e 's/;NoNewPrivileges/NoNewPrivileges/' /etc/systemd/system/caddy.service
  fi

  rm -r /tmp/caddy

  if [ "$1" = update ] ;then
    systemctl daemon-reload
    systemctl restart caddy
    whiptail --msgbox "Caddy updated!" 8 32
  else
    # Start Caddy and enable the auto-start it at boot
    systemctl start caddy
    systemctl enable caddy

    grep -q Caddy dp.cfg || echo Caddy >> dp.cfg
    whiptail --msgbox "  Caddy installed!
  Caddy run as 'www-data' user and group

  You can modify the Caddy configuration files:
  Caddyfile configuration: '/etc/caddy/Caddyfile'
  Service configuration: '/etc/systemd/system/caddy.service'" 12 64
  fi
else
  echo "Caddy is already installed"
fi

if grep "$1" /etc/caddy/Caddyfile ;then
  # Remove the app entry from the Caddyfile
  sed "/$1/,/}/d" /etc/caddy/Caddyfile

  # Restart Caddy to apply the changes
  systemctl restart caddy
fi
