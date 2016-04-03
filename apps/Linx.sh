#!/bin/sh

[ $1 = update ] || [ $1 = remove ] && rm -rf ~/linx-server*
[ $1 = remove ] && sh sysutils/services.sh remove Linx && userdel -r linx && whiptail --msgbox "Linx removed!" 8 32 && break

# Define port
port=$(whiptail --title "Linx port" --inputbox "Set a port number for Linx" 8 48 "8081" 3>&1 1>&2 2>&3)

# Create a linx user
useradd -m linx

# Go to its directory
cd /home/linx

# Get the latest Linx-server release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/andreimarcu/linx-server/releases/latest)

# Only keep the version number in the url
ver=${ver#*/v}

[ $ARCH = 86 ] && ARCH=386

wget https://github.com/andreimarcu/linx-server/releases/download/v$ver/linx-server-v${ver}_linux-$ARCH

# Change the owner from root to linx
chown linx:linx /home/linx/linx-server-v${ver}_linux-$ARCH

# Set the file executable
chmod +x linx-server-v${ver}_linux-$ARCH

# Add SystemD process and run the server
cat > "/etc/systemd/system/linx.service" <<EOF
[Unit]
Description=Linx Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/linx
ExecStart=/home/linx/linx-server-v${ver}_linux-$ARCH -config /home/linx/config.ini
User=linx
Group=linx
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "bind = :$port
siteurl = $IP" > config.ini

whiptail --msgbox "Linx installed!

Open your browser to http://$URL:$port" 12 64
