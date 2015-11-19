#!/bin/sh
cd $HOME
$install nginx git

# Nginx
cat <<NGINX >/etc/nginx/sites-enabled/default
server {
    listen 81;
    server_name localhost;
    index index.html;
    location /var/www/laverna
}
NGINX
service nginx restart

# Download
mkdir /var/www/
cd /var/www/
git clone -b gh-pages https://github.com/Laverna/static-laverna

whiptail --msgbox "Laverna successfully installed!

Open http://$DOMAIN in your browser" 12 48
