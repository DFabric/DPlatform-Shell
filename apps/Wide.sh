#!/bin/sh

whiptail --yesno "Yes to install from binary (only for amd64 and i386)

No if your prefer to build from sources (Can be long)" 12 48
case $? in

  # Download Binary
  0) mkdir wide-1.5.0
  cd wide-1.5.0
  [ $ARCH = amd64 ] && url=https://www.dropbox.com/s/bsyavnyr8a2ys4l/wide-1.5.0-linux-amd64.tar.gz
  [ $ARCH = 86 ] && url=https://www.dropbox.com/s/ht2bzj0i03jcpjf/wide-1.5.0-linux-386.tar.gz
  # Download the arcive
  download $url -O wide.tar.gz "Downloading the Wide 1.5.0 archive..."

  # Extract the downloaded archive and remove it
  extract wide.tar.gz "xzf -" "Extracting the files from the archive..."
  rm wide.tar.gz;;

  # Build Wide
  1) $install golang
  cd
  git clone https://github.com/b3log/wide

  # Get dependencies
  go get
  go get github.com/visualfc/gotools github.com/nsf/gocode github.com/bradfitz/goimports

  # Compile wide
  go build

  cd wide;;
esac

# Run Wide
#wide

whiptail --msgbox "Wide installed!

Run the 'wide' file, and
Open browser: http://$URL:7070" 10 64
