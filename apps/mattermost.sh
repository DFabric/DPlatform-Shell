#!/bin/sh
#http://docs.mattermost.org/install/Production-Debian/index.html

## Setup Database Server
sudo apt-get install postgresql postgresql-contrib
sudo -i -u postgres

# Create the Mattermost database
psql CREATE DATABASE mattermost;

# Create the Mattermost
psql CREATE USER mmuser WITH PASSWORD 'mmuser_password';

# Grant the user access to the Mattermost database
psql GRANT ALL PRIVILEGES ON DATABASE mattermost to mmuser;
psql \q


## Setup Mattermost Server

# Download the latest Mattermost Server by typing:
wget https://github.com/mattermost/platform/releases/download/v1.0.0/mattermost.tar.gz

# Install Mattermost under /opt
cd /opt

# Unzip the Mattermost Server
tar -xvzf mattermost.tar.gz

# Create the storage directory for files, located at /mattermost/data
sudo mkdir -p /opt/mattermost/data

# Create a system user and group called mattermost that will run this service
useradd -r mattermost -U

# Set the mattermost account as the directory owner
sudo chown -R mattermost:mattermost /opt/mattermost

# Add yourself to the mattermost group to ensure you can edit these files:
sudo usermod -aG mattermost USERNAME

#Configure Mattermost Server by editing the config.json file at /opt/mattermost/config
cd /opt/mattermost/config

# Edit the file
vi config.json
replace "DataSource": "mmuser:mostest@tcp(dockerhost:3306)/mattermost_test?charset=utf8mb4,utf8" with
"DataSource": "postgres://mmuser:mmuser_password@10.10.10.1:5432/mattermost?sslmode=disable&connect_timeout=10"
Optionally you may continue to edit configuration settings in config.json or use the System Console described in a later section to finish the configuration.

# Run the Mattermost Server
cd /opt/mattermost/bin && ./platform

# Setup Mattermost to use the systemd init daemon which handles supervision of the Mattermost process
sudo touch /etc/init.d/mattermost
cat > /etc/init.d/mattermost <<EOF
#! /bin/sh
### BEGIN INIT INFO
# Provides:          mattermost
# Required-Start:    $network $syslog
# Required-Stop:     $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Mattermost Group Chat
# Description:       Mattermost: An open-source Slack
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Mattermost"
NAME=mattermost
MATTERMOST_ROOT=/opt/mattermost
MATTERMOST_GROUP=mattermost
MATTERMOST_USER=mattermost
DAEMON="$MATTERMOST_ROOT/bin/platform"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

. /lib/lsb/init-functions

do_start() {
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    start-stop-daemon --start --quiet \
        --chuid $MATTERMOST_USER:$MATTERMOST_GROUP --chdir $MATTERMOST_ROOT --background \
        --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
        || return 1
    start-stop-daemon --start --quiet \
        --chuid $MATTERMOST_USER:$MATTERMOST_GROUP --chdir $MATTERMOST_ROOT --background \
        --make-pidfile --pidfile $PIDFILE --exec $DAEMON \
        || return 2
}

#
# Function that stops the daemon/service
#
do_stop() {
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 \
        --pidfile $PIDFILE --exec $DAEMON
    RETVAL="$?"
    [ "$RETVAL" = 2 ] && return 2
    # Wait for children to finish too if this is a daemon that forks
    # and if the daemon is only ever run from this initscript.
    # If the above conditions are not satisfied then add some other code
    # that waits for the process to drop all resources that could be
    # needed by services started subsequently.  A last resort is to
    # sleep for some time.
    start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 \
        --exec $DAEMON
    [ "$?" = 2 ] && return 2
    # Many daemons don't delete their pidfiles when they exit.
    rm -f $PIDFILE
    return "$RETVAL"
}

case "$1" in
start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
        do_start
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
stop)
        [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
        do_stop
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
status)
    status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
    ;;
restart|force-reload)
        #
        # If the "reload" option is implemented then remove the
        # 'force-reload' alias
        #
        log_daemon_msg "Restarting $DESC" "$NAME"
        do_stop
        case "$?" in
        0|1)
                do_start
                case "$?" in
                        0) log_end_msg 0 ;;
                        1) log_end_msg 1 ;; # Old process is still running
                        *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
        *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
*)
        echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
        exit 3
        ;;
esac

exit 0
EOF

# Make sure that /etc/init.d/mattermost is executable
chmod +x /etc/init.d/mattermost


## Set up Nginx Server

# Install Nginx on Debian
sudo apt-get install nginx

# Create a configuration for Mattermost
sudo touch /etc/nginx/sites-available/mattermost
echo "{ server_name mattermost.example.com; location / { client_max_body_size 50M; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; proxy_set_header X-Frame-Options SAMEORIGIN; proxy_pass http://localhost:8065; } }" >> /etc/nginx/sites-available/mattermost

# Remove the existing file with
sudo rm /etc/nginx/sites-enabled/default

# Link the mattermost config by typing:
sudo ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost

# Restart Nginx by typing:
sudo service nginx restart


<<NEED_REVIEW
## Set up Nginx with SSL (Recommended)

#You will need a SSL cert from a certificate authority.
#For simplicity we will generate a test certificate.
mkdir ~/cert
cd ~/cert
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mattermost.key -out mattermost.crt

#Input the following info

Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:California
Locality Name (eg, city) []:Palo Alto
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Example LLC
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:mattermost.example.com
Email Address []:admin@mattermost.example.com

# Modify the file at `/etc/nginx/sites-available/mattermost` and add the following lines

server { listen 80; server_name mattermost.example.com; return 301 https://$server_name$request_uri; }

server { listen 443 ssl; server_name mattermost.example.com;

ssl on;
ssl_certificate /home/mattermost/cert/mattermost.crt;
ssl_certificate_key /home/mattermost/cert/mattermost.key;
ssl_session_timeout 5m;
ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
ssl_prefer_server_ciphers on;
}
# add to location / above
location / {
    gzip off;
    proxy_set_header X-Forwarded-Ssl on;
}
NEED_REVIEW

whiptail --msgbox "Mattermost successfully installed!

Open http://your_hostname.com:8065 in your browser" 16 60
