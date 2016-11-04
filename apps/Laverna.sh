#!/bin/sh

[ "$1" = update ] && { git -C /var/www/static-laverna pull; whiptail --msgbox "Laverna updated!" 8 32; break; }
[ "$1" = remove ] && { /var/www/static-laverna; rm /etc/nginx/sites-*/laverna; systemctl restart nginx; whiptail --msgbox "Laverna  updated!" 8 32; break; }

# Define port
port=$(whiptail --title "Laverna port" --inputbox "Set a port number for Laverna" 8 48 "8007" 3>&1 1>&2 2>&3)

# Create www-data user and group
groupadd -g 33 www-data
useradd \
  -g www-data --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 33 www-data

# Go to its directory
mkdir -p /var/www
cd /var/www

#  Clone the prebuilt static version
git clone https://github.com/Laverna/static-laverna

# Change the owner from root to www-data
chown -R www-data:www-data /var/www/static-laverna

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

if hash caddy 2>/dev/null ;then
  cat >> /etc/caddy/Caddyfile <<EOF
http://$access:$port {
    root /var/www/static-laverna
    log /var/log/laverna.log
}

EOF
  systemctl restart caddy
else
  $install nginx
  # Create Nginx configuration file
  cat > /etc/nginx/sites-available/laverna <<EOF
server  {
    listen $access:$port;
    root /var/www/static-laverna;
    index index.html;
    server_name \$hostname;
    error_log /var/log/nginx/laverna.log warn;
    access_log /var/log/nginx/laverna.log combined;
        location ~* \.(jpg|jpeg|gif|css|png|js|ico|html)$ {
          access_log off;
          expires max;
        }
        location ~ /\.ht {
          deny all;
        }
}
EOF

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/laverna /etc/nginx/sites-enabled/laverna

# Delete the default nginx server block
rm -f /etc/nginx/sites-enabled/default
# Reload Nginx
systemctl restart nginx
fi

whiptail --msgbox "Laverna installed!

Open http://$URL:$port in your browser" 12 48
