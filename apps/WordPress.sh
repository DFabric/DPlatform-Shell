#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && userdel -r wordpress && whiptail --msgbox && (rm /etc/nginx/sites-*/wordpress; systemctl nginx restart) && "WordPress removed!" 8 32 && break


# Define port
port=$(whiptail --title "WordPress port" --inputbox "Set a port number for WordPress" 8 48 "80" 3>&1 1>&2 2>&3)

$install php7 mariadb-server || $install php5 mariadb-server

# Add WordPress user
useradd -m wordpress

mkdir -p /var/www/wordpress
cd /var/www/wordpress
git clone https://github.com/GeekPress/WP-Quick-Install
php WP-Quick-Install/index.php

# Change the owner from root to laverna
chown -R wordpress:wordpress /var/www/wordpress

if hash caddy 2>/dev/null
then
 cat >> /etc/caddy/Caddyfile <<EOF
$IP {
   root /var/www/wordpress
}
EOF
systemctl restart caddy
elif
then
 $install nginx
 # Create Nginx configuration file
 cat > /etc/nginx/sites-available/wordpress <<EOF
 server {
   listen 80 default_server;

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

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Delete the default nginx server block
rm /etc/nginx/sites-enabled/default
# Reload Nginx
systemctl nginx restart

whiptail --msgbox "WordPress installed!

Open http://$URL in your browser!" 10 64
