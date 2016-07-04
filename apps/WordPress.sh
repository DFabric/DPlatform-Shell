#!/bin/sh

[ $1 = update ] && { whiptail --msgbox "Not availabe yet!" 8 32; exit; }
[ $1 = remove ] && { rm /etc/nginx/sites-*/wordpress; systemctl nginx restart; userdel wordpress; whiptail --msgbox "WordPress removed!" 8 32; exit; }


# Define port
port=$(whiptail --title "WordPress port" --inputbox "Set a port number for WordPress" 8 48 "8089" 3>&1 1>&2 2>&3)

$install mariadb-server php5-mysql php5-fpm

# Add WordPress user
useradd wordpress

mkdir -p /var/www/wordpress
cd /var/www/wordpress
git clone https://github.com/GeekPress/WP-Quick-Install
php WP-Quick-Install/index.php

# Change the owner from root to laverna
chown -R wordpress /var/www/wordpress

[ $IP = $LOCALIP ] && access=$IP || access=

if hash caddy 2>/dev/null ;then
 cat >> /etc/caddy/Caddyfile <<EOF
http://$access:$port {
  root /var/www/wordpress
  gzip
  fastcgi / 127.0.0.1:9000 php
  rewrite {
    if {path} not_match ^\/wp-admin
    to {path} {path}/ /index.php?_url={uri}
  }
}

EOF
systemctl restart caddy
else
  $install nginx
  # Create Nginx configuration file
  cat > /etc/nginx/sites-available/wordpress <<EOF
 server {
   listen $access:$port;

   root /var/www/wordpress;
   index index.php index.html index.htm;

   location / {
           try_files $uri $uri/ /index.php?q=$uri&$args;
   }

   error_page 404 /404.html;

   error_page 500 502 503 504 /50x.html;
   location = /50x.html {
           root /usr/share/nginx/html;
   }

   location ~ \.php$ {
           try_files $uri =404;
           fastcgi_split_path_info ^(.+\.php)(/.+)$;
           fastcgi_pass unix:/var/run/php5-fpm.sock;
           fastcgi_index index.php;
           include fastcgi_params;
           fastcgi_params;
   }
 }
EOF
fi

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default
# Reload Nginx
systemctl nginx restart

whiptail --msgbox "WordPress installed!

Open http://$URL:$port in your browser!" 10 64
