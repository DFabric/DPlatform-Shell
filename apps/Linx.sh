#!/bin/sh

[ "$1" = update ] || [ "$1" = remove ] && rm -rf ~/linx-server*
[ "$1" = remove ] && { sh sysutils/service.sh remove Linx; userdel -rf linx; whiptail --msgbox "Linx removed." 8 32; break; }

# Defining the port
port=$(whiptail --title "Linx port" --inputbox "Set a port number for Linx" 8 48 "8087" 3>&1 1>&2 2>&3)

# Create a linx user
useradd -mrU linx

# Go to its directory
cd /home/linx

# Get the latest Linx-server release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/andreimarcu/linx-server/releases/latest)

# Only keep the version number in the url
ver=${ver#*/v}

arch=amd64
[ $ARCHf = arm ] && arch=arm
[ $ARCH = 86 ] && arch=386

# Download and extract the arcive
download "https://github.com/andreimarcu/linx-server/releases/download/v$ver/linx-server-v${ver}_linux-$arch" "Downloading the archive..."

# Set the file executable
chmod +x linx-server-v${ver}_linux-$arch

cat > config.ini <<EOF
bind = :$port
# Need to fix
# siteurl = $IP
EOF

# Change the owner from root to linx
chown -R linx: /home/linx

# Add a systemd service and run the server
cat > "/etc/systemd/system/linx.service" <<EOF
[Unit]
Description=Linx Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/linx
ExecStart=/home/linx/linx-server-v${ver}_linux-$arch -config /home/linx/config.ini
User=linx
Group=linx
Restart=always
RestartSec=9
[Install]
WantedBy=multi-user.target
EOF

systemctl start linx
systemctl enable linx

[ "$1" = install ] && state=installed || state=$1d
whiptail --msgbox "Linx $state!

Open your browser to http://$URL:$port" 10 64
