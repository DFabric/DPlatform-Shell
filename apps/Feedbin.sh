#!/bin/sh

[ $1 = update ] && { git -C /home/feedbin pull; chown -R feedbin: /home/feedbin; whiptail --msgbox "Feedbin updated!" 8 32; break; }
[ $1 = remove ] && { sh sysutils/service.sh remove Feedbin; userdel -rf feedbin; groupdel feedbin; whiptail --msgbox "Feedbin  updated!" 8 32; break; }

# Create a feedbin user
useradd -mrU feedbin

# Go to its directory
cd /home/feedbin

# https://github.com/feedbin/feedbin/blob/master/doc/INSTALL-fedora.md

# Feedbin Dependencies
# Install a bunch of dependencies
[ $PKG = rpm ] && $install gcc gcc-c++ git libcurl-devel libxml2-devel libxslt-devel postgresql postgresql-server postgresql-contrib postgresql-devel rubygems ruby-devel rubygem-bundler ImageMagick-devel opencv-devel
[ $PKG = deb ] && $install gcc g++  libcurl4-openssl-dev libxml2-dev libxslt-dev postgresql postgresql-contrib postgresql-dev rubygems ruby-dev ruby-bundler libmagick++-6.q16-dev libopencv-dev

# Get Feedbin
git clone https://github.com/feedbin/feedbin .

# Install Ruby dependencies
bundle

# Start the service
systemctl start postgresql

# If you want PostgreSQL to auto-start
systemctl enable postgresql

# Create a PostgreSQL users
sudo -u postgres createuser feedbin

# Make yourself a PostgreSQL admin
sudo -u postgres createuser -s $USER

# Setup databases:
# In the feedbin directory
rake db:setup

# Change the owner from root to feedbin
chown -R feedbin: /home/feedbin

# Run Feedbin
bundle exec foreman start & rackup

whiptail --msgbox "Feedbin installed!

Open http://$URL:9292 in your browser,
select SQlite and complete the installation." 10 64
