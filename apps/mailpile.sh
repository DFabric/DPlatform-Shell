#!/bin/sh
apt-get install gnupg openssl python-virtualenv python-pip python-lxml
apt-get install git

# clone Mailpile, docs and plugins (submodules) to your machine
git clone --recursive https://github.com/mailpile/Mailpile.git

# move into the newly created source repo
cd Mailpile

# create a virtual environment directory
virtualenv -p /usr/bin/python2.7 --system-site-packages mp-virtualenv

# activate the virtual Python environment
source mp-virtualenv/bin/activate

pip install -r requirements.txt

# enter the Mailpile source directory
cd Mailpile

# activate the Mailpile virtual Python environment
source mp-virtualenv/bin/activate

# run Mailpile
./mp

# update your Mailpile
git pull

# update any submodules (documentation, plug-ins)
git submodule update
