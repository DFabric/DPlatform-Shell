#!/bin/sh

[ "$1" = update ] && { /home/git/gitea/gitea update; chown -R git: /home/git/gitea; whiptail --msgbox "Gitea updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Gitea; rm -rf /home/git/gitea; whiptail --msgbox "Gitea removed." 8 32; break; }

# Prerequisites
$install sqlite3

# Create a git user
useradd -mrU git

# Go to its directory
mkdir /home/git/gitea
cd /home/git/gitea

# Get the latest Gogs release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/go-gitea/gitea/releases/latest)

# Only keep the version number in the url
ver=${ver#*v}

case $ARCH in
	amd64) arch=amd64;;
	86) arch=386;;
	arm64) arch=arm64;;
	armv7) arch=arm-7;;
	armv6) arch=arm-6;;
esac

# Download the archive
download "https://dl.gitea.io/gitea/$ver/gitea-$ver-linux-$arch -O /home/git/gitea/gitea" "Downloading the Gitea $ver binary..."

# Start the service and enable it to start up at boot
download "https://raw.githubusercontent.com/go-gitea/gitea/master/scripts/systemd/gitea.service -O /etc/systemd/system/gitea.service" "Downloading the Gitea systemd service..."

# Change the owner from root to git
chown -R git: /home/git/gitea

# Start the service and enable it to start at boot
systemctl start gitea
systemctl enable gitea

<<CADDY
if hash caddy 2>/dev/null ;then
  [ $IP = $LOCALIP ] && access=$IP || access=0.0.0.0
  cat >> /etc/caddy/Caddyfile <<EOF
http://$access:3000 {
    proxy / localhost:3000 {
        except /css /fonts /js /img
    }
    root /home/git/gitea/public
}

EOF
  systemctl restart caddy
fi
CADDY

whiptail --msgbox "Gitea installed!

Open http://$URL:3000 in your browser,
select SQlite and complete the installation." 10 64
