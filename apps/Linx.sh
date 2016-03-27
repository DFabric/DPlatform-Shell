#!/bin/sh

[ $1 = update ] || [ $1 = remove ] && rm -rf ~/linx-server*
[ $1 = remove ] && sh sysutils/services.sh remove Linx && rm -rf ~/linx-server* && whiptail --msgbox "Linx removed!" 8 32 && break

# Define port
whiptail --title "Linx port" --clear --inputbox "Enter a port number for Linx. default:[8080]" 8 32 2> /tmp/temp
read port < /tmp/temp
port=${port:-8080}

# Get the latest Linx-server release
ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/andreimarcu/linx-server/releases/latest)

# Only keep the version number in the url
ver=$(echo $ver | awk '{ver=substr($0, 58); print ver;}')

[ $ARCH = 86 ] && ARCH=386

cd
wget https://github.com/andreimarcu/linx-server/releases/download/v$ver/linx-server-v${ver}_linux-$ARCH

# Add SystemD process and run the server
sh $DIR/sysutils/services.sh Linx "$HOME/linx-server-v${ver}_linux-$ARCH -bind :$port" $HOME

whiptail --msgbox "Linx $ver installed!

Open your browser to http://$IP:$port" 12 64
