#!/bin/sh

# Install and configure the necessary dependencies
sudo apt-get install curl openssh-server ca-certificates postfix apt-transport-https
curl https://packages.gitlab.com/gpg.key | sudo apt-key add -

# Add the GitLab package server and install the package

sudo curl -o /etc/apt/sources.list.d/gitlab_ce.list "https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/config_file.list?os=debian&dist=wheezy" && sudo apt-get update

sudo apt-get install gitlab-ce

# Configure and start GitLab
sudo gitlab-ctl reconfigure

echo Username: root
echo Password: 5iveL!fe 
