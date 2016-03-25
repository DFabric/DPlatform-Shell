#!/bin/sh

# https://github.com/swanson/stringer/blob/master/docs/VPS.md
# Dependencies installation

# Ubuntu/Debian
if [ $PKG = deb ]
  then $install libxml2-dev libxslt-dev libcurl4-openssl-dev libpq-dev libsqlite3-dev build-essential postgresql libreadline-dev ruby

# CentOS/Fedora
elif [ $PKG = rpm ]
  then $install libxml2-devel libxslt-devel curl-devel postgresql-devel sqlite-devel  make automake gcc gcc-c++ postgresql-server readline-devel openssl-devel
  service postgresql initdb && service postgresql start

# Arch Linux
elif [ $PKG = pkg ]
  then $install postgresql base-devel libxml2 libxslt curl sqlite readline postgresql-libs

  # Arch specific instructions for setting up postgres
  systemd-tmpfiles --create postgresql.conf
  chown -c -R postgres:postgres /var/lib/postgres
  sudo su - postgres -c "initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'"
  systemctl start postgresql
  systemctl enable postgresql
else
  exit
fi

## Set up the database
# Create a postgresql user to own the database Stringer will use, you will need to create a password too, make a note of it.
sudo -u postgres createuser -D -A -P stringer
# Now create the database Stringer will use
sudo -u postgres createdb -O stringer stringer_live

## Create your stringer user
# We will run stringer as it's own user for security
useradd stringer -m

# We also need to install bundler which will handle Stringer's dependencies
gem install bundler

# We will also need foreman to run our app
gem install foreman

# Install Stringer and set it up
# Grab Stringer from github
git clone https://github.com/swanson/stringer
cd stringer

# Use bundler to grab and build Stringer's dependencies
bundle install

# Stringer uses environment variables to configure the application. Edit these values to reflect your settings.
echo 'export DATABASE_URL="postgres://stringer:stringer@localhost/stringer_live"' >> $HOME/.bash_profile
echo 'export RACK_ENV="production"' >> $HOME/.bash_profile
echo "export SECRET_TOKEN=`openssl rand -hex 20`" >> $HOME/.bash_profile
source ~/.bash_profile


# Tell stringer to run the database in production mode, using the postgres database you created earlier.
rake db:migrate RACK_ENV=production

chmod -R stringer /home/stringer

# Run the application:
foreman start

# Set up a cron job to parse the rss feeds.
sudo -u stringer crontab -l | { cat; echo "SHELL=/bin/sh
PATH=/bin/ruby:/bin/:/usr/bin:/usr/local/bin/:/usr/local/sbin
*/10 * * * *  source $HOME/.bash_profile; cd $HOME/stringer/; bundle exec rake fetch_feeds;"; } | crontab -

whiptail --msgbox "Stringer successfully installed!

Open http://$IP:5000 in your browser" 12 64
