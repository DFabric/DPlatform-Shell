#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet!" 8 32; exit; }
[ "$1" = remove ] && { rm /etc/nginx/sites-*/nextcloud; systemctl restart nginx; rm -rf /var/www/nextcloud; whiptail --msgbox "NextCloud removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "NextCloud port" --inputbox "Set a port number for NextCloud" 8 48 "8084" 3>&1 1>&2 2>&3)

# PHP5 fallback if PHP7 not available
php_fpm=/run/php/php7.0-fpm.sock
$install mariadb-server php7.0-mysql php7.0-fpm php7.0-zip php7.0-gd php7.0-mbstring || echo "PHP7 not available, fallback to PHP5" && $install mariadb-server php-mysql php-fpm php-zip php-gd php-mbstring && php_fpm=/var/run/php5-fpm.sock

mkdir -p /var/www/nextcloud

download "https://download.nextcloud.com/server/installer/setup-nextcloud.php -O /var/www/nextcloud/index.php" "Downloading the NextCloud wizard..."

# Change the owner from root to www-data
chown -R www-data:www-data /var/www/nextcloud

if hash caddy 2>/dev/null ;then
  [ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0
 cat >> /etc/caddy/Caddyfile <<EOF
http://$access:$port {
  root /var/www/nextcloud
  gzip
  fastcgi / 127.0.0.1:9000 php
  rewrite {
    to {path} {path}/ /index.php?_url={uri}
  }
}

EOF
systemctl restart caddy
else
  [ $IP = $LOCALIP ] && access=$IP: || access=
  $install nginx
  # Create Nginx configuration file
  cat > /etc/nginx/sites-available/nextcloud <<EOF
server {
  listen $access$port;

  root /var/www/nextcloud/;
  index index.php index.html index.htm;
  access_log /var/log/nginx/nextcloud.access.log;
  error_log /var/log/nginx/nextcloud.error.log;

  location / {
    try_files $uri $uri/ /index.php;
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
ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/nextcloud

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default

# Reload Nginx
systemctl restart nginx

whiptail --msgbox "NextCloud wizard installed!

Open http://$URL:$port in your browser to proceed to the installation." 10 64
