#!/bin/sh

if [ $1 = update ]
then
  cd /var/www/FreshRSS
  git reset --hard
  git pull
  chown -R www-data:www-data .
  chmod -R g+w ./data/
  whiptail --msgbox "FreshRSS updated!" 8 32
  break
fi
[ $1 = remove ] && /var/www/FreshRSS && whiptail --msgbox && (rm /etc/nginx/sites-*/freshrss; systemctl restart nginx) && crontab -r && whiptail --msgbox "FreshRSS removed!" 8 32 && break

# Define port
port=$(whiptail --title "FreshRSS port" --inputbox "Set a port number for FreshRSS" 8 48 "8086" 3>&1 1>&2 2>&3)

# https://github.com/FreshRSS/FreshRSS
$install php5 php5-curl php5-gmp php5-intl php5-json php5-sqlite nginx

cd /var/www

git clone https://github.com/FreshRSS/FreshRSS

# Set the rights so that your Web browser can access the files
chown -R www-data:www-data FreshRSS
chmod -R g+w ./data/

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

# Create Nginx configuration file
cat > /etc/nginx/sites-available/freshrss <<EOF
server {
  listen $port;
  server_name \$hostname;
  root /var/www/FreshRSS/p;
  index index.php index.html index.htm;
  access_log /var/log/nginx/freshrss.access.log;
  error_log /var/log/nginx/freshrss.error.log;
  location ~ ^.+?\.php(/.*)?$ {
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include snippets/fastcgi-php.conf;
    #fastcgi_param PATH_INFO $fastcgi_path_info;
    #include fastcgi_params;
    #fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }
  #location / {
  #  try_files $uri $uri/ index.php;
  #}
}
EOF

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/freshrss /etc/nginx/sites-enabled/freshrss

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default
# Reload Nginx
systemctl restart nginx
fi

# Add a Cron job to launch the update script every hour
crontab -l | { cat; echo "*/30 * * * * /usr/bin/php /var/www/FreshRSS/actualize_script.php >/dev/null 2>&1"; } | crontab -

whiptail --msgbox "FreshRSS installed!

Open http://$URL:$port in your browser." 10 64
