#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; exit; }
[ "$1" = remove ] && { rm /etc/nginx/sites-*/wordpress; systemctl restart nginx; rm -rf /var/www/wordpress; whiptail --msgbox "WordPress removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "WordPress port" --inputbox "Set a port number for WordPress" 8 48 "8089" 3>&1 1>&2 2>&3)

# PHP5 fallback if PHP7 not available
php_fpm=/run/php/php7.0-fpm.sock
$install mariadb-server php7.0-mysql php7.0-fpm || echo "PHP7 not available, fallback to PHP5" && $install mariadb-server php5-mysql php5-fpm && php_fpm=/var/run/php5-fpm.sock

# Create www-data user and group
groupadd -g 33 www-data
useradd \
  -g www-data --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 33 www-data

mkdir -p /var/www/wordpress
cd /var/www/wordpress
git clone https://github.com/GeekPress/WP-Quick-Install
mv WP-Quick-Install/wp-quick-install/* .
rm -rf WP-Quick-Install

# Change the owner from root to www-data
chown -R www-data:  /var/www/

if hash caddy 2>/dev/null ;then
  [ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0
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
  [ $IP = $LOCALIP ] && access=$IP: || access=
  $install nginx
  # Create Nginx configuration file
  cat > /etc/nginx/sites-available/wordpress <<EOF
server {
  listen $access$port default_server;
  server_name \$hostname;
  root /var/www/wordpress;
  index index.php index.html index.htm;
  charset UTF-8;
  location / {
    try_files $uri/ /index.php?$args;
  }
  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:$php_fpm;
    fastcgi_index index.php;
    include fastcgi.conf;
  }
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|eot|otf|ttf|woff)$ {
    add_header Access-Control-Allow-Origin *;
    access_log off; log_not_found off; expires 30d;
  }
  location = /robots.txt { access_log off; log_not_found off; }
  location ~ /\. { deny all; access_log off; log_not_found off; }
}
EOF
fi

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default

# Reload Nginx
systemctl restart nginx

whiptail --msgbox "WordPress wizard installed!

Open http://$URL:$port in your browser to proceed to the installation." 10 64
