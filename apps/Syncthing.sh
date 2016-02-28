#!/bin/sh


if [ $PKG = deb ]
then
  # Add the release PGP keys:
  curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

  # Add the "release" channel to your APT sources:
  echo "deb http://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list

  # Update and install syncthing:
  sudo update
  $install syncthing

  # Access the web GUI from other computers
  sed -i "s/host: '127.0.0.1:8384 ',/host: '0.0.0.0:8384',/g" ~/.config/syncthing/config.xml

  # Add supervisor process, configure and start Syncthing
  sh sysutils/supervisor.sh Syncthing syncthing $HOME/.config/syncthing
else
  # Get the latest Syncthing release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/syncthing/syncthing/releases/latest)

  # Only keep the version number in the url
  ver=$(echo $ver | awk '{ver=substr($0, 54); print ver;}')
  [ $ARCH = 86 ] && ARCH=386
  cd
  wget https://github.com/syncthing/syncthing/releases/download/v$ver/syncthing-linux-$ARCH-v$ver.tar.gz
  tar -xzf syncthing-linux-$ARCH-v$ver.tar.gz
  rm syncthing-linux-$ARCH-v$ver.tar.gz

  # Exectute Syncthing to generate the config file, and then exit
  whiptail --msgbox "Press CTRL-C after syncthing generate the .config/syncthing folder to able to connect yourself to the Web GUI from external computers" 10 64
  syncthing

  # Access the web GUI from other computers
  sed -i "s/host: '127.0.0.1:8384 ',/host: '0.0.0.0:8384',/g" ~/.config/syncthing/config.xml

  # Add supervisor process, configure and start Syncthing
  sh sysutils/supervisor.sh Syncthing $HOME/syncthing-linux-*/syncthing $HOME/.config/syncthing
fi

whiptail --msgbox "Syncthing successfully installed! Install Syncthing in your computer too to sync files!

You might need to setup a port forward for 22000/TCP.
Port 8384 to be able to access the web GUI from other computers

The admin GUI starts automatically and remains available on http://$IP:8384" 16 64
