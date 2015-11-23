#!/bin/sh

# https://github.com/mailpile/Mailpile/wiki/Getting-started-on-linux
cd $HOME

$install gnupg openssl python-virtualenv python-pip python-lxml git

# clone Mailpile, docs and plugins (submodules) to your machine
git clone --recursive https://github.com/mailpile/Mailpile.git

# Setup your virtual environment
# move into the newly created source repo
cd Mailpile

# create a virtual environment directory
virtualenv -p /usr/bin/python2.7 --system-site-packages mp-virtualenv

# activate the virtual Python environment
source mp-virtualenv/bin/activate

# Install the dependencies
pip install -r requirements.txt

# Run Mailpile
./mp

# update your Mailpile
git pull

# update any submodules (documentation, plug-ins)
git submodule update

# https://github.com/mailpile/Mailpile/wiki/Accessing-The-GUI-Over-Internet
$install nginx

cat > /etc/nginx/sites-enabled/mailpile <<EOF
server {
  listen 80;
  server_name server.com;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl;
  server_name server.com;

  # see https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  # for notes on the good SSL on nginx
  ssl_certificate /etc/nginx/ssl/server.com.crt;
  ssl_certificate_key /etc/nginx/ssl/server.com.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
  ssl_prefer_server_ciphers   on;
  ssl_session_cache shared:SSL:10m;
  add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
  ssl_dhparam /etc/nginx/ssl/dhparam.pem;

  location / {
    access_log /var/log/nginx/mailpile_access.log;
    error_log /var/log/nginx/mailpile_error.log info;

    proxy_pass http://127.0.0.1:33411;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
EOF


whiptail --msgbox "Mailpile successfully installed!
You should need to open port 33411 and 993
Open http://$IP:33411 in your browser

To run Mailpile again:
cd Mailpile
source mp-virtualenv/bin/activate
./mp" 16 48
