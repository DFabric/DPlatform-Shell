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
  wget $url -O wide.tar.gz 2>&1 | \
  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --gauge "Downloading the archive..." 6 64 0

  # Extract the downloaded archive and remove it
  (pv -n wide.tar.gz | tar xzf -) 2>&1 | whiptail --gauge "Extracting the files from the archive..." 6 64 0
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
wide

whiptail --msgbox "Wide installed!

Open browser: http://$URL:7070" 10 64
