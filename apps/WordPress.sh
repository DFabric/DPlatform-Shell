#!/bin/sh

[ $1 = update ] && { whiptail --msgbox "Not availabe yet!" 8 32; exit; }
[ $1 = remove ] && { rm /etc/nginx/sites-*/wordpress; systemctl restart nginx; rm -rf /var/www/wordpress; whiptail --msgbox "WordPress removed!" 8 32; exit; }

# Define port
port=$(whiptail --title "WordPress port" --inputbox "Set a port number for WordPress" 8 48 "8089" 3>&1 1>&2 2>&3)

# PHP5 fallback if PHP7 not available
php_fpm=/run/php/php7.0-fpm.sock
$install mariadb-server php7.0-mysql php7.0-fpm || echo "PHP7 not available, fallback to PHP5" && $install mariadb-server php5-mysql php5-fpm && php_fpm=/var/run/php5-fpm.sock

php WP-Quick-Install/wp-quick-install/index.php

cd /var/www
git clone https://github.com/GeekPress/WP-Quick-Install
mv WP-Quick-Install wordpress

# Change the owner from root to www-data
chown -R www-data:www-data  /var/www/wordpress

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

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

  root /var/www/wordpress/wp-quick-install;
  index index.php index.html index.htm;
  access_log /var/log/nginx/wordpress.access.log;
  error_log /var/log/nginx/wordpress.error.log;

  location / {
    try_files $uri $uri/ /index.php?q=$uri&$args;
  }

  error_page 404 /404.html;

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
   root /usr/share/nginx/html;
  }

 location ~ \.php$ {
   fastcgi_pass unix:$php_fpm;
   fastcgi_split_path_info ^(.+\.php)(/.*)$;
   include snippets/fastcgi-php.conf;
   #include fastcgi_params;
   #fastcgi_params;
  }
}
EOF
fi

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default

# Reload Nginx
systemctl restart nginx

whiptail --msgbox "WordPress installed!

Open http://$URL:$port in your browser!" 10 64
