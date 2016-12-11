#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Ghost; rm -rf /opt/mattermost; rm /etc/nginx/sites-*/mattermost; systemctl restart nginx; userdel -rf mattermost; groupdel mattermost; whiptail --msgbox "Mattermost removed." 8 32; break; }

if [ $archf != amd64 ] ;then
    echo "Mattermost requires an amd64 machine, but this one is $archf."
    exit 1
fi

# Defining the port
port=$(whiptail --title "Mattermost port" --inputbox "Set a port number for Mattermost" 8 48 "8065" 3>&1 1>&2 2>&3)

$install postgresql nginx

# Create a git user
useradd -rU mattermost

INSTALL_DIR=/opt/mattermost
config=$INSTALL_DIR/config/config.json
MM_USER=mmuser
MM_PWD=mmuser_password
MM_DBNAME=mattermost
DB_HOST=db

mkdir $INSTALL_DIR
cd $INSTALL_DIR

# Download the arcive
download "https://releases.mattermost.com/3.5.1/mattermost-3.5.1-linux-amd64.tar.gz -O mattermost.tar.gz" "Downloading the Mattermost archive..."

# Extract the downloaded archive and remove it
extract mattermost.tar.gz "xzf -" "Extracting the files from the archive..."
rm mattermost.tar.gz

psql -v ON_ERROR_STOP=1 --username "postgres" <<- EOSQL
    CREATE DATABASE $MM_DBNAME;
    CREATE USER $MM_USER WITH PASSWORD $MM_PWD;
    GRANT ALL PRIVILEGES ON DATABASE $MM_DBNAME to $MM_USER;
EOSQL

printf "Configure database connection..."
if [ ! -f $config ] ;then
    cp /config.template.json $config
    sed -Ei "s/DB_HOST/$DB_HOST/" $config
    sed -Ei "s/DB_PORT/5432/" $config
    sed -Ei "s/MM_USERNAME/$MM_USER/" $config
    sed -Ei "s/MM_PASSWORD/$MM_PWD/" $config
    sed -Ei "s/MM_DBNAME/$MM_DBNAME/" $config
    echo OK
else
    echo SKIP
fi

sed -i "/DataSource/ s|mmuser.*|postgres://$MM_USER:$MM_PWD@127.0.0.1:5432/mattermost?sslmode=disable\&connect_timeout=10\",|" $config

# Change the owner from root to mattermost
chown -R mattermost: /opt/mattermost
chmod -R g+w /opt/mattermost

cat > /etc/systemd/system/mattermost.service <<EOF
[Unit]
Description=Mattermost is an open source, self-hosted Slack-alternative
After=syslog.target network.target

[Service]
Type=simple
User=mattermost
Group=mattermost
ExecStart=/opt/mattermost/bin/platform
PrivateTmp=yes
WorkingDirectory=/opt/mattermost
Restart=always
RestartSec=30
LimitNOFILE=49152

[Install]
WantedBy=multi-user.target
EOF

systemctl enable mattermost

systemctl start mattermost

[ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0

# Create Nginx configuration file
cat > /etc/nginx/sites-available/mattermost <<EOF
server {
server_name \$hostname;
  location / {
     client_max_body_size 50M;
     proxy_set_header Upgrade $http_upgrade;
     proxy_set_header Connection "upgrade";
     proxy_set_header Host $http_host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto $scheme;
     proxy_set_header X-Frame-Options SAMEORIGIN;
     proxy_pass http://$access:$port;
  }
}
EOF

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost

# Reload Nginx
systemctl restart nginx

whiptail --msgbox "Mattermost installed!

Open http://$URL:$port in your browser" 12 64
