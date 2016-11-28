# Contributing to DPlatform

#### Thanks to your interest for the DPlatform project! This document is attended to provide advanced informations for people who wants to add their contribution to the DPlatform ShellCore of DPlatfor.

## Shell Style Guide

DPlatform is made in a POSIX Shell script. Therefore, your contribution must comply to this following coding standards:
- POSIX compliance (`#!/bin/sh`): all commands must work with sh, dash, bash, ksh, zsh
- Unless required no semicolons
- Indentation whenever is possible (for example except for `cat <<EOF EOF`)
- Use a space and a semicolon just before `then` and `do`: `if/elif [ ] ;then`, and `while/for ;do`
- If you have simple conditions, use one-line booleans expressions like `[ "$1" = "" ] && [ ] || command` instead of `if/elif/else`

## Application installation script structure

Each application installation scripts are built upon a same structure. Here we suppose that you application is called **MyApp**

First at the begining af each application script file, there are command to update and remove itself.
```sh
[ "$1" = update ] && { git -C /home/myapp/MyApp pull; whiptail --msgbox "MyApp updated!" 8 32; break; }
[ "$1" = remove ] && { sh sysutils/services.sh remove MyApp; userdel -rf myapp; groupdel myapp; whiptail --msgbox "MyApp removed." 8 32 ; break; }
```
Depending of your app, you can ask to the user to write some arguments, like a port number.
``` sh
# Defining the port
port=$(whiptail --title "MyApp port" --inputbox "Set a port number for MyApp" 8 48 "80" 3>&1 1>&2 2>&3)
```

Next, the prerequisites
```sh
# Prerequisites of MyApp that have builtin support in DPlatform's sysutils, for example NodeJS or MongoDB
. sysutils/Node.js.sh
. sysutils/MongoDB.sh

# Add MyApp user
useradd -mrU myapp

# Go to myapp user directory
cd /home/myapp

# Install MyApp dependencies, for example python, gcc...
$install python gcc
```

Follows the install instructions, that depends of your app
```sh
# If your app has a git repository
git clone https://github.com/MyApp/MyApp

# Download the archive
download "https://myapp.com/myapp_v1.0.0.tar.gz -O myapp.tar.gz" "Downloading the archive..."

# Extract the downloaded archive and remove it
extract myapp.tar.gz "tar xzf -" "Extracting the files from the archive..."
rm myapp.tgz

cd MyApp
```

Here is the following variables that you can use for your installations commands
```sh
$PKG={deb|rpm|pkg}
$ARCHf={x86|arm}
$ARCH={86|amd64|armv6|armv7|arm64}

# Detect distribution (from /etc/os-release)
$DIST={Debian|Ubuntu|Fedora|CentOS...}  # $ID
$DIST_VER={8|7|16.04|14.04|24|23|8|7|6...}  # $VERSION_ID

# Finally change the owner from root to myapp
chown -R myapp: /home/myapp
```

Create a systemd service for your app
```sh
# Create the systemd service
cat > "/etc/systemd/system/myapp.service" <<EOF
[Unit]
Description=MyApp Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/myapp/MyApp
ExecStart=/usr/bin/node server.js
Environment=ROOT_URL=http://$IP:$port/ PORT=$port
User=myapp
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start the service and enable it to start on boot
systemctl start myapp
systemctl enable myapp
```
You can also use the builtin systemd service creation of DPlatform
```sh
# Add systemd process and run the server
sh sysutils/services.sh MyApp "/usr/bin/node /usr/bin/MyApp" /home/myapp/MyApp myapp
# This command with its arguments correspond to
# sh ServiceCreationScriptPath ServiceName "ExecStart=" WorkingDirectory= User=

```
Finally, print a message box to inform that the installation is finished and the URL access of your app
```sh
whiptail --msgbox "MyApp installed!

Open http://$URL:$port in your browser." 10 64
```
Finally, add your new application to the `dplatform.sh` main menu next to anothers `MyApp "MyApp description" \`. Add also its description on "Available apps" like `- [MyApp](https://myapp_website) - Description`
