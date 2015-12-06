# DPlatform [ALPHA]
##### Do you want a Cloud Storage, a Chat Platform, a CMS Website or even a VPN? Deploy applications/services efficiently and turn your server, even a cheap Raspberry Pi, to a cloud platform.
Mainly, but not limited, for Debian based x86(-64) and ARM(v7 preferably at minimum, like the Raspberry Pi 2) systems. Red Hat based x86(-64) systems have some support, and Arch Linux have also little support.
Development is still active. Most things should work, but problems could occur, more testing is needed
Please feel free to open an issue and create a pull request, all contributions are welcome!

## Features and available apps (few still need work)

 - Set a domain name to use a name instead of the computer's IP address
 - Torrent - Access to [Deluge](http://deluge-torrent.org/) and [Transmission](http://www.transmissionbt.com/) torrent web interface
 - [Agar.io Clone](https://github.com/huytd/agar.io-clone) - Agar.io clone written with Socket.IO and HTML5 canvas
 - [Ajenti](http://ajenti.org/core/) - Web admin panel
 - [(WordPress) Calypso](https://developer.wordpress.com/calypso/) - A single interface built for reading, writing, and managing all of your WordPress sites in one place
 - [Dillinger](http://dillinger.io/) - Dillinger is a cloud-enabled, mobile-ready, offline-storage, AngularJS powered HTML5 Markdown editor
 - [Docker](https://www.docker.com/) - Open container engine platform for distributed application
 - [EtherCalc](https://ethercalc.net/) - Web spreadsheet, Node.js port of Multi-user SocialCalc
 - [Etherpad](http://etherpad.org/) - Real-time collaborative document editor
 - [GitLab CE](https://about.gitlab.com/features/) - Open source Version Control to collaborate on code
 - [Gogs](http://gogs.io/) - Gogs(Go Git Service), a painless self-hosted Git Service
 - [Ghost](https://ghost.org/) - Simple and powerful blogging/publishing platform
 - [JS Bin](http://jsbin.com) - JS Bin is an open source collaborative web development debugging tool
 - [KeystoneJS](http://keystonejs.com/) - Node.js CMS & Web Application Platform
 - [Laverna](https://laverna.cc/) - Laverna is a JavaScript note taking application with Markdown editor and encryption support
 - [Let's Chat](https://sdelements.github.io/lets-chat/) - Self-hosted chat app for small teams
 - [Linx](https://github.com/andreimarcu/linx-server) - Self-hosted file/code/media sharing website
 - [Mailpile](https://www.mailpile.is/) - A free & open modern, fast email client with user-friendly encryption and privacy features
 - [Mattermost](http://mattermost.org/) - Open source, on-prem Slack-alternative
 - [Mattermost-GitLab](https://github.com/mattermost/mattermost-integration-gitlab) - GitLab Integration Service for Mattermost
 - [Modoboa](https://github.com/tonioo/modoboa) - Mail hosting made simple - Deployed thanks to [modoboa-installer](https://github.com/modoboa/modoboa-installer)
 - [MongoDB](https://www.mongodb.org/) - MongoDB is the database for today’s applications: innovative, fast time-to-market, globally scalable, reliable, and inexpensive to operate.
 - [Mumble](http://www.mumble.info/) - Voicechat utility
 - [NodeBB](https://nodebb.org/) - Node.js based community forum built for the modern web
 - [Node.js](https://nodejs.org/) - Install Node.js - [nvm](https://github.com/creationix/nvm) optional
 - [OpenVPN](https://openvpn.net/) - Open source secure tunneling VPN daemon - Deployed thanks to [openvpn-install](https://github.com/Nyr/openvpn-install)
 - [Rocket.Chat](https://rocket.chat/) - The Ultimate Open Source WebChat Platform
 - [RetroPie](https://github.com/RetroPie/RetroPie-Setup) - Setup Raspberry PI with RetroArch emulator and various cores
 - [Seafile](https://seafile.com) - Cloud storage with file encryption and group sharing - MariaDB version deployed thanks to [seafile-server-installer](https://github.com/SeafileDE/seafile-server-installer)
 - [Stringer](https://github.com/swanson/stringer) - A self-hosted, anti-social RSS reader
 - [Syncthing](https://syncthing.net/) - Open Source Continuous File Synchronization
 - [Taiga.Io](https://taiga.io/) - Agile, Free and Open Source Project Management Platform - Deployed thanks to [taiga-scripts](https://github.com/taigaio/taiga-scripts)
 - [Taiga-LetsChat](https://github.com/taigaio/taiga-contrib-letschat) - Taiga contrib plugin for Let's Chat integration
 - [Wekan](https://wekan.io/) - Collaborative Trello-like kanban board application - Deployed thanks to https://github.com/anselal/wekan
 - [Wide](https://wide.b3log.org/) - Web-based IDE for Teams using Go(lang)

## Install

First, clone the git project
```
sudo apt-get -y install git
git clone https://github.com/j8r/DPlatform
```
Go to the DPlatform directory and run DPlatform
```
cd DPlatform && sudo sh dplatform.sh
```

## License

DPlatform is distributed under the [MIT License](http://opensource.org/licenses/MIT)
