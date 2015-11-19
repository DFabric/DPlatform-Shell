#!/bin/sh

# https://github.com/mailpile/Mailpile/wiki/Getting-started-on-linux
cd $HOME

$install gnupg openssl python-virtualenv python-pip python-lxml git

# clone Mailpile, docs and plugins (submodules) to your machine
git clone --recursive https://github.com/mailpile/Mailpile.git

# Setup your virtual environment
# move into the newly created source repo
cd Mailpile

# create a virtual environment directory
virtualenv -p /usr/bin/python2.7 --system-site-packages mp-virtualenv

# activate the virtual Python environment
source mp-virtualenv/bin/activate

# Install the dependencies
pip install -r requirements.txt

# Run Mailpile
./mp

# update your Mailpile
git pull

# update any submodules (documentation, plug-ins)
git submodule update

whiptail --msgbox "Mailpile successfully installed!
You should need to open port 33411 and 993
Open http://$DOMAIN:33411 in your browser

To run Mailpile again:
cd Mailpile
source mp-virtualenv/bin/activate
./mp" 16 48
