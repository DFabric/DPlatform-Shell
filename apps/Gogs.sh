#!/bin/sh

[ $1 = update ] && ./home/git/gogs/gogs update && whiptail --msgbox "Gogs updated!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Gogs && userdel -r git && whiptail --msgbox "Gogs removed!" 8 32 && break

# Prerequisites
$install sqlite3

# Create a git user
useradd -m git

# Go to its directory
cd /home/git

# Get the latest Gogs release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/gogits/gogs/releases/latest)

# Only keep the version number in the url
ver=${ver#*v}

# Download, extract the archive
if [ $ARCH = amd64 ] || [ $ARCH = 86 ]
then
  [ $ARCH = 86 ] && ARCH=386
  wget https://cdn.gogs.io/gogs_v${ver}_linux_$ARCH.tar.gz
  tar zxvf gogs_v${ver}_linux_$ARCH.tar.gz
  rm gogs_v${ver}_linux_$ARCH.tar.gz
elif [ $ARCH = arm ]
then
  # Install unzip if not installed
  hash unzip 2>/dev/null || $install unzip

  wget https://cdn.gogs.io/gogs_v${ver}_raspi2.zip
  unzip gogs_v${ver}_raspi2.zip
  rm gogs_v${ver}_raspi2.zip
fi
# Add SystemD process, configure and start Gogs
cp /home/git/gogs/scripts/systemd/gogs.service /etc/systemd/system

# Change the owner from root to git
chown -R git:git /home/git/gogs

# Start the service and enable it to start up on boot
systemctl start gogs
systemctl enable gogs

if hash caddy 2>/dev/null
  cat >> /etc/caddy/Caddyfile <<EOF
$IP {
    proxy / localhost:3000 {
        except /css /fonts /js /img
    }
    root /home/git/gogs/public
}

EOF
  systemctl caddy restart
fi

whiptail --msgbox "Gogs installed!

Open http://$URL:3000 in your browser,
select SQlite and complete the installation." 10 64
