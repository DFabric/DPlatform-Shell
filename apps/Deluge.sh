#!/bin/sh

[ "$1" = update ] && { $install deluged deluge-web; whiptail --msgbox "Deluge updated!" 8 32; break; }
[ "$1" = remove ] && { $remove deluged deluge-web; whiptail --msgbox "Deluge  updated!" 8 32; break; }

# http://dev.deluge-torrent.org/wiki/UserGuide/Service/systemd
$install deluged deluge-web

# For security it is best to run a service with a specific user and group. You can create one using the following command:
adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge
# This creates a new system user and group named deluge with no login access and home directory: /var/lib/deluge

# Migration from init.d
# Remove old init.d files
service deluged stop
rm /etc/init.d/deluged
update-rc.d deluged remove

# Logging
# Create a log directory for Deluge and give the service user (e.g. deluge), full access:
mkdir -p /var/log/deluge
chown -R deluge:deluge /var/log/deluge
chmod -R 750 /var/log/deluge
# The deluge log directory is now configured so that user deluge has full access, group deluge read only and everyone else denied access. The umask specified in the services sets the permission of new log files.

# Enable log Rotation
cat > /etc/logrotate.d/deluge <<EOF
/var/log/deluge/*.log {
        rotate 4
        weekly
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                systemctl restart deluged >/dev/null 2>&1 || true
                systemctl restart deluge-web >/dev/null 2>&1 || true
        endscript
}
EOF

# Deluge Daemon (deluged) Service
cat > /etc/systemd/system/deluged.service <<EOF
[Unit]
Description=Deluge Bittorrent Client Daemon
After=network-online.target

[Service]
Type=simple
User=deluge
Group=deluge
UMask=007

ExecStart=/usr/bin/deluged -d -l /var/log/deluge/daemon.log -L warning

Restart=on-failure

# Configures the time to wait before service is stopped forcefully.
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
EOF
# Start the service and enable it to start up on boot
systemctl start deluged
systemctl enable deluged

# Deluge Web UI (deluge-web) Service
cat > /etc/systemd/system/deluge-web.service <<EOF
[Unit]
Description=Deluge Bittorrent Client Web Interface
After=network-online.target

[Service]
Type=simple

User=deluge
Group=deluge
UMask=027

ExecStart=/usr/bin/deluge-web -l /var/log/deluge/web.log -L warning

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
# Start the service and enable it to start up on boot
systemctl start deluge-web
systemctl enable deluge-web

whiptail --msgbox "Deluge installed!

Open http://$URL:8112 in your browser to access to the web UI
Password: deluge " 10 64
