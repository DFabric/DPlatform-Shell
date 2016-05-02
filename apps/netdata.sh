#!/bin/sh

# Update, rebuild and install netdata
[ $1 = update ] && git -C netdada pull && .$HOME/netdata/netdata-installer.sh && whiptail --msgbox "netdata updated!" 8 32 && exit
[ $1 = remove ] && sh sysutils/Caddy.sh && sh sysutils/service.sh remove netdata && { rm -rf ~/netdata; rm -rf /etc/netdata; rm -r /usr/sbin/netdata; } && whiptail --msgbox "netdata removed!" 8 32 && exit

# Define port
port=$(whiptail --title "netdata port" --inputbox "Set a port number for netdata" 8 48 "19999" 3>&1 1>&2 2>&3)

# Debian / Ubuntu
[ $PKG = deb ] && $install zlib1g-dev gcc make git autoconf autogen automake pkg-config

# Centos / Redhat
[ $PKG = rpm ] && $install zlib-devel gcc make git autoconf autogen automake pkgconfig

# ArchLinux
[ $PKG = pkg ] && pacman -S --needed base-devel libmnl libnetfilter_acct zlib

# Install and run netdata
cd
# download it - the directory 'netdata.git' will be created
git clone https://github.com/firehol/netdata --depth=1
cd netdata

# build it
./netdata-installer.sh

# Copy the SystemD to its directory
cp system/netdata-systemd /etc/systemd/system/netdata.service
systemctl enable netdata

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
<<EOF
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

    location / {
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_pass_request_headers on;
        proxy_set_header Connection "keep-alive";
        proxy_store off;
    }
}
EOF
fi

whiptail --msgbox "netdata installed!

Open http://$URL:$port in your browser" 10 64
