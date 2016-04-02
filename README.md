# DPlatform [ALPHA]
![logo](https://j8r.github.io/DPlatform/img/logo.svg)
 **DPlatform** helps you to install applications easily and manage them.
#### Would you want to have your own Cloud Storage, Chat Platform, CMS Website or VPN? To have applications you need simply, quickly without an headache putting time in complicated commands and configurations? Deploy applications/services easily and turn your server, even a cheap Raspberry Pi, to a cloud platform.
![main](https://raw.githubusercontent.com/j8r/DPlatform/gh-pages/img/main.png)
![install](https://raw.githubusercontent.com/j8r/DPlatform/gh-pages/img/install.png)

## Features
 - Install applications easily.
 - Manage Apps Services with SystemD services integration -View apps services status, one click start/stop, auto-start at boot and auto-restart if down unexpectively
 - Update/Remove installed apps easily with two clicks
 - [Caddy](https://caddyserver.com/) implementation - Secure HTTPS web access for some apps
 - Determine your IPv4, IPv6, LocalIP and your hostname
 - IP address and FQDN domain name configuration help (generally in .com, .net...), or via [localtunnel](https://localtunnel.me/)

 [![deploy](https://raw.githubusercontent.com/j8r/DPlatform/gh-pages/img/deploy.png)](https://j8r.github.io/DPlatform/)
## Available apps (few still need work)
 - [Rocket.Chat](https://rocket.chat/) - The Ultimate Open Source WebChat Platform
 - [Gogs](http://gogs.io/) - Gogs(Go Git Service), a painless self-hosted Git Service
 - [Syncthing](https://syncthing.net/) - Open Source Continuous File Synchronization
 - [OpenVPN](https://openvpn.net/) - Open source secure tunneling VPN daemon - Deployed thanks to [openvpn-install](https://github.com/Nyr/openvpn-install)
 - [Mumble](http://www.mumble.info/) - Voicechat utility
 - [Seafile](https://seafile.com) - Cloud storage with file encryption and group sharing - MariaDB version deployed thanks to [seafile-server-installer](https://github.com/SeafileDE/seafile-server-installer)
 - [Mopidy](https://www.mopidy.com/) - Mopidy plays music from local disk, Spotify, SoundCloud, Google Play Music, and more - With [Mopify](https://github.com/dirkgroenen/mopidy-mopify) - Web Client for Mopidy Music Server and the Pi MusicBox
 - [OwnCloud](https://owncloud.org/) - Access & share your files, calendars, contacts, mail & more from any device, on your terms
 - Torrent - Access to [Deluge](http://deluge-torrent.org/) and [Transmission](http://www.transmissionbt.com/) torrent web interface
 - [Agar.io Clone](https://github.com/huytd/agar.io-clone) - Agar.io clone written with Socket.IO and HTML5 canvas
 - [Ajenti](http://ajenti.org/core/) - Ajenti is a Linux & BSD web admin panel
 - [Cuberite](http://cuberite.org/) - A Minecraft-compatible multiplayer game server that is written in C++ and designed to be efficient with memory and CPU
 - [Deluge](http://deluge-torrent.org/) with WebUI - A lightweight, Free Software, cross-platform BitTorrent client
 - [Dillinger](http://dillinger.io/) - A cloud-enabled, mobile-ready, offline-storage, AngularJS powered HTML5 Markdown editor
 - [Docker](https://www.docker.com/) - Open container engine platform for distributed application
 - [EtherCalc](https://ethercalc.net/) - Web spreadsheet, Node.js port of Multi-user SocialCalc
 - [EtherDraw](https://github.com/JohnMcLear/draw) - A real time collaborative drawing tool using nodejs, socket.io & paper.js
 - [Etherpad](http://etherpad.org/) - Real-time collaborative document editor
 - [Feedbin](https://feedbin.com/) - Feedbin is a simple, fast and nice looking RSS reader
 - [GitLab CE](https://about.gitlab.com/features/) - Open source Version Control to collaborate on code
 - [Ghost](https://ghost.org/) - Simple and powerful blogging/publishing platform
 - [Jitsi Meet](https://jitsi.org/Projects/JitsiMeet) - Secure, Simple and Scalable Video Conferences
 - [JS Bin](http://jsbin.com) - An open source collaborative web development debugging tool
 - [KeystoneJS](http://keystonejs.com/) - Node.js CMS & Web Application Platform
 - [Laverna](https://laverna.cc/) - A JavaScript note taking application with Markdown editor and encryption support
 - [Let's Chat](https://sdelements.github.io/lets-chat/) - Self-hosted chat app for small teams
 - [Linx](https://github.com/andreimarcu/linx-server) - Self-hosted file/code/media sharing website
 - [Mailpile](https://www.mailpile.is/) - A free & open modern, fast email client with user-friendly encryption and privacy features
 - [Mattermost](http://mattermost.org/) - Open source, on-prem Slack-alternative
 - [Modoboa](https://github.com/tonioo/modoboa) - Mail hosting made simple - Deployed thanks to [modoboa-installer](https://github.com/modoboa/modoboa-installer)
 - [MongoDB](https://www.mongodb.org/) - The database for today’s applications: innovative, fast time-to-market, globally scalable, reliable, and inexpensive to operate
 - [netdata](http://netdata.firehol.org/) - A highly optimized Linux daemon providing real-time performance monitoring for Linux systems, Applications, SNMP devices, over the web!
 - [NodeBB](https://nodebb.org/) - Node.js based community forum built for the modern web
 - [Node.js](https://nodejs.org/) - Install Node.js with [NodeSource](https://nodesource.com/)(root) or [nvm](https://github.com/creationix/nvm)(non-root)
 - [Reaction Commerce](https://reactioncommerce.com/) - A completely open source JavaScript platform for today's premier ecommerce experiences
 - [RetroPie](https://github.com/RetroPie/RetroPie-Setup) - Setup Raspberry PI with RetroArch emulator and various cores
 - [StackEdit](https://stackedit.io/) - A full-featured, open-source Markdown editor based on PageDown.
 - [Stringer](https://github.com/swanson/stringer) - A self-hosted, anti-social RSS reader
 - [Taiga.Io](https://taiga.io/) - Agile, Free and Open Source Project Management Platform - Deployed thanks to [taiga-scripts](https://github.com/taigaio/taiga-scripts)
 - [Transmission](https://www.transmissionbt.com/) with WebInterface - A cross-platform BitTorrent client that is open source and designed for easy, powerful use
 - [Wekan](https://wekan.io/) - Collaborative Trello-like kanban board application - Deployed thanks to https://github.com/anselal/wekan
 - [Wide](https://wide.b3log.org/) - Web-based IDE for Teams using Go(lang)
 - [WordPress](https://wordpress.org/) - Web software you can use to create a beautiful website, blog, or app
 - [(WordPress) Calypso](https://developer.wordpress.com/calypso/) - A single interface built for reading, writing, and managing all of your WordPress sites in one place

## Install
Clone the DPlatform git project, and then run it:
``` sh
sudo apt-get -y install git
cd ~ # Or whatever directory you want
git clone https://github.com/j8r/DPlatform
```
`sudo sh ~/DPlatform/dplatform.sh`

Next times, only run this last command for DPlatform


## Requirements

A recent GNU/Linux operating system with **SystemD** is highly recommended:

Debian 8 Jessie and derivatives like Ubuntu and Raspbian. Full support, well tested

CentOS 7, Fedora and other RHEL derivatives. Good support, not fully tested

Arch Linux. Partial support, not tested

A x86, x86-64 or armv[6,7,8] CPU.

Development is still active. Most things should work, but problems could occur, more testing is needed.
Please feel free to open an issue and create a pull request, all contributions are welcome!

## Roadmap

 ***The main goals of DPlatform are the independence, the freedom and the security. Therefore all installations and configurations provided through this set of shell tools are TOTALLY independents of it***

 - [1] Install apps efficiently through a terminal UI - In progress
 - (2) DPlatform Web GUI to manage apps easily - Early prototypes started
 - (3) Build a custom image with DPlatform Web GUI auto-configuration - Planned
 - DNS and secure firewall pass-trough via [localtunnel](https://localtunnel.me/)
 - Enhance the security. Nginx reverse proxy, [Let's Encrypt](https://letsencrypt.org/) certificate

## Contributors - Special thanks
[@cryptono](https://github.com/cryptono) (torito) - testing

## License
Copyright (c) 2015-2016 Julien Reichardt - [MIT License](http://opensource.org/licenses/MIT) (MIT)
