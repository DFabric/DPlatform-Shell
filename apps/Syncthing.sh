#!/bin/sh

[ "$1" = update ] && { whiptail --msgbox "Not available yet." 8 32; exit; }
[ "$1" = remove ] && [ $PKG = deb ] && { sh sysutils/service.sh remove Syncthing; $remove syncthing; rm -rf ~/.config/syncthing; whiptail --msgbox "Syncthing removed." 8 32; break; }
[ "$1" = remove ] && { sh sysutils/service.sh remove Syncthing; rm -rf ~/syncthing-linux-*; rm -rf ~/.config/syncthing; whiptail --msgbox "Syncthing removed." 8 32; break; }

[ $IP = $LOCALIP ] && access=$IP || access=

if [ $PKG = deb ] ;then
  # Add the release PGP keys:
  curl -s https://syncthing.net/release-key.txt | apt-key add -

  # Add the "release" channel to your APT sources:
  echo "deb http://apt.syncthing.net/ syncthing release" | tee /etc/apt/sources.list.d/syncthing.list

  # Update and install syncthing:
  sudo apt-get update
  $install syncthing

  # Access the web GUI from other computers
  sed -i 's/127.0.0.1:8384/$access:8384/g' ~/.config/syncthing/config.xml

  # Add a systemd service, configure and start Syncthing
  sh sysutils/service.sh Syncthing syncthing $HOME/syncthing-linux-*
else
  # Get the latest Syncthing release
  ver=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/syncthing/syncthing/releases/latest)
  # Only keep the version number in the url
  ver=${ver#*v}

  arch=amd64
  [ $ARCHf = arm ] && arch=arm
  [ $ARCH = 86 ] && arch=386
  # Download the arcive
  download "https://github.com/syncthing/syncthing/releases/download/v$ver/syncthing-linux-$arch-v$ver.tar.gz" "Downloading the Syncthing $ver archive..."

  # Extract the downloaded archive and remove it
  extract syncthing-linux-$arch-v$ver.tar.gz "xzf -" "Extracting the files from the archive..."
  cd syncthing-linux-$arch-v$ver

  # Move Syncthing bin to the system bin directory
  mv syncthing /usr/local/bin/
  # Move the systemd Syncthing service to the systemd directory
  mv etc/linux-systemd/*/* /lib/systemd/system
  # Setting working directory to user path
  sed -i 's|WorkingDirectory=/home/'$USER'/syncthing-linux-\*|WorkingDirectory=/home/'$USER'/|g' /etc/systemd/system/syncthing.service
  # Putting the whole path in ExecStart
  sed -i 's|ExecStart=syncthing|ExecStart=/usr/bin/syncthing|g' /etc/systemd/system/syncthing.service
  
  # Remove the useless service and it's extracted folder
  rm syncthing-linux-$arch-v$ver*

  # Exectute Syncthing to generate the config file
  /usr/local/bin/syncthing -generate=~/.config/syncthing

  # Access the web GUI from other computers
  sed -i 's/127.0.0.1:8384/$access:8384/g' ~/.config/syncthing/config.xml

  # Add a systemd service, configure and start Syncthing
  sh sysutils/service.sh Syncthing $HOME/syncthing-linux-$arch-v$ver/syncthing $HOME/syncthing-linux-$arch-v$ver
fi

whiptail --msgbox "Syncthing installed! Install Syncthing in your computer too to sync files!

You might need to setup a port forward for 22000/TCP.
Port 8384 to be able to access the web GUI from other computers

The admin GUI starts automatically and remains available on http://$URL:8384" 14 64
