#!/bin/sh

[ $1 = update ] || [ $1 = remove ] && rm -rf ~/linx-server*
[ $1 = remove ] && sh sysutils/services.sh remove Linx && rm -rf ~/linx-server* && whiptail --msgbox "Linx removed!" 8 32 && break

# Get the latest Linx-server release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/andreimarcu/linx-server/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 58); print ver;}')

[ $ARCH = 86 ] && ARCH=386

cd
wget https://github.com/andreimarcu/linx-server/releases/download/v$ver/linx-server-v${ver}_linux-$ARCH
chmod +x linx-server*

# Add SystemD process and run the server
sh $DIR/sysutils/services.sh Linx $HOME/linx-server* $HOME

whiptail --msgbox "Linx $ver successfully installed!

Open your browser to http://$IP:8080" 12 64
