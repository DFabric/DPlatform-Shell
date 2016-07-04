#!/bin/sh

# Update, rebuild and install netdata
[ $1 = update ] && { git -C netdada pull; ~/netdata/netdata-installer.sh; whiptail --msgbox "netdata updated!" 8 32; exit; }
[ $1 = remove ] && { rm /etc/nginx/sites-*/netdata; systemctl restart nginx; sh sysutils/service.sh remove netdata; ~/netdata/netdata-uninstaller.sh --force; rm -r ~/netdata; whiptail --msgbox "netdata removed!" 8 32; exit; }

# Define port
port=$(whiptail --title "netdata port" --inputbox "Set a port number for netdata" 8 48 "19999" 3>&1 1>&2 2>&3)

# https://github.com/firehol/netdata/wiki/Installation
# ArchLinux
if [ $PKG = pkg ] ;then
  $install netdata

else
  # Debian / Ubuntu
  [ $PKG = deb ] && $install zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config

  # Centos / Fedora / Redhat
  [ $PKG = rpm ] && $install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig

  cd
  # download it - the directory 'netdata' will be created
  git clone https://github.com/firehol/netdata --depth=1

  # build it, install it, start it
  ~/netdata/netdata-installer.sh

  [ $IP = $LOCALIP ] && access=$IP || access=

  # Run netdata via Caddy's proxying
  if hash caddy 2>/dev/null ;then
    cat >> /etc/caddy/Caddyfile <<EOF
http://$access:$port {
    proxy / localhost:19999
}
EOF
    systemctl restart caddy

  # Pass netdata via a nginx
  else
    $install nginx
    cat > /etc/nginx/sites-available/netdata <<EOF
upstream backend {
    # the netdata server
    server 127.0.0.1:19999;
    keepalive 64;
}

server {
    # nginx listens to this
    listen $access:$port;

    # the virtual host name of this
    server_name \$hostname;

    #location / {
    #    proxy_set_header X-Forwarded-Host $host;
    #    proxy_set_header X-Forwarded-Server $host;
    #    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #    proxy_pass http://backend;
    #    proxy_http_version 1.1;
    #    proxy_pass_request_headers on;
    #    proxy_set_header Connection "keep-alive";
    #    proxy_store off;
    #}
}
EOF
  # Symlink sites-enabled to sites-available
  ln -s /etc/nginx/sites-available/netdata /etc/nginx/sites-enabled/netdata

  # Delete the default nginx server block
  rm -f /etc/nginx/sites-enabled/default

  # Reload Nginx
  systemctl restart nginx
  fi
fi

whiptail --msgbox "netdata installed!

Open http://$URL:$port in your browser" 10 64
