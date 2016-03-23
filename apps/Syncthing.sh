#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && [ $PKG = deb ] sh sysutils/services.sh remove Syncthing && $remove syncthing && rm -rf ~/.config/syncthing && whiptail --msgbox "Syncthing removed!" 8 32 && break
[ $1 = remove ] && sh sysutils/services.sh remove Syncthing && rm -rf ~/syncthing-linux-* && rm -rf ~/.config/syncthing && whiptail --msgbox "Syncthing removed!" 8 32 && break

if [ $PKG = deb ]
then
  # Add the release PGP keys:
  curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

  # Add the "release" channel to your APT sources:
  echo "deb http://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list

  # Update and install syncthing:
  sudo apt-get update
  $install syncthing

  # Access the web GUI from other computers
  sed -i 's/127.0.0.1:8384/:8384/g' ~/.config/syncthing/config.xml

  # Add SystemD process, configure and start Syncthing
  sh sysutils/services.sh Syncthing syncthing $HOME/syncthing-linux-*
else
  # Get the latest Syncthing release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/syncthing/syncthing/releases/latest)

  # Only keep the version number in the url
  ver=$(echo $ver | awk '{ver=substr($0, 54); print ver;}')
  [ $ARCH = 86 ] && ARCH=386
  wget https://github.com/syncthing/syncthing/releases/download/v$ver/syncthing-linux-$ARCH-v$ver.tar.gz
  tar -xvzf syncthing-linux-$ARCH-v$ver.tar.gz
  cd syncthing-linux-$ARCH-v$ver
  # Move Syncthing bin to the system bin directory
  mv syncthing /usr/local/bin/
  # Move the SystemD Syncthing service to the SystemD directory
  mv etc/linux-systemd/*/* /lib/systemd/system
  # Remove the useless service and it's extracted folder
  rm syncthing-linux-$ARCH-v$ver*

  # Exectute Syncthing to generate the config file
  /usr/local/bin/syncthing -generate=~/.config/syncthing

  # Access the web GUI from other computers
  sed -i 's/127.0.0.1:8384/:8384/g' ~/.config/syncthing/config.xml

  # Add SystemD process, configure and start Syncthing
  sh sysutils/services.sh Syncthing $HOME/syncthing-linux-*/syncthing $HOME/syncthing-linux-*
fi

whiptail --msgbox "Syncthing successfully installed! Install Syncthing in your computer too to sync files!

You might need to setup a port forward for 22000/TCP.
Port 8384 to be able to access the web GUI from other computers

The admin GUI starts automatically and remains available on http://$IP:8384" 16 64
