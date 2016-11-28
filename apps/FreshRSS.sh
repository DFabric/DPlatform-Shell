#!/bin/sh

[ "$1" = update ] && { cd /var/www/FreshRSS; git reset --hard; git pull; chown -R www-data:www-data ./; chmod -R g+w ./data/; whiptail --msgbox "FreshRSS updated!" 8 32; break; }
[ "$1" = remove ] && { rm /etc/nginx/sites-*/freshrss; systemctl restart nginx; crontab -ru www-data; whiptail --msgbox "FreshRSS removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "FreshRSS port" --inputbox "Set a port number for FreshRSS" 8 48 "8086" 3>&1 1>&2 2>&3)

# https://github.com/FreshRSS/FreshRSS

# PHP5 fallback if PHP7 not available
php_fpm=/run/php/php7.0-fpm.sock
$install php7.0 php7.0-curl php7.0-gmp php7.0-intl php7.0-json php7.0-sqlite php7.0-fpm php7.0-xml nginx || echo "PHP7 not available, fallback to PHP5" && $install php5 php5-curl php5-gmp php5-intl php5-json php5-sqlite php5-fpm nginx && php_fpm=/var/run/php5-fpm.sock

# Create www-data user and group
groupadd -g 33 www-data
useradd \
  -g www-data --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 33 www-data

cd /var/www

git clone https://github.com/FreshRSS/FreshRSS

# Replace the default Origine theme by the more modern Flat theme
sed -i "s/'theme' => 'Origine'/'theme' => 'Flat'/" FreshRSS/data/users/_/config.default.php

# Set the rights so that your Web browser can access the files
chown -R www-data:www-data FreshRSS
chmod -R g+w FreshRSS/./data/

<<APACHE2
<VirtualHost *:$port>
ServerAdmin me@mydomain.com
DocumentRoot /config/www//FreshRSS/p
DirectoryIndex index.html index.php
<Directory />
</Directory>
<Directory /config/www/FreshRSS/p>
Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
</Directory>

</VirtualHost>
APACHE2

[ $IP = $LOCALIP ] && access=$IP: || access=

# Create Nginx configuration file
cat > /etc/nginx/sites-available/freshrss <<EOF
server {
  listen $access$port;
  server_name \$hostname;
  root /var/www/FreshRSS/p;
  index index.php index.html index.htm;
  access_log /var/log/nginx/freshrss.access.log;
  error_log /var/log/nginx/freshrss.error.log;

  location / {
    try_files $uri $uri/ /index.php?q=$uri&$args;
  }

  error_page 404 /404.html;

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
   root /usr/share/nginx/html;
  }

  location ~ ^.+?\.php(/.*)?$ {
    fastcgi_pass unix:$php_fpm;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include snippets/fastcgi-php.conf;
    #fastcgi_param PATH_INFO $fastcgi_path_info;
    #include fastcgi_params;
    #fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }
}
EOF

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/freshrss /etc/nginx/sites-enabled/freshrss

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default
# Reload Nginx
systemctl restart nginx

# Add a Cron job for the www-data user to launch the update script every hour
crontab -u www-data -l | { sudo -u www-data cat; echo "0 * * * * /usr/bin/php /var/www/FreshRSS/app/actualize_script.php >/dev/null 2>&1"; } | sudo -u www-data crontab -

whiptail --msgbox "FreshRSS installed!

Open http://$URL:$port in your browser." 10 64
