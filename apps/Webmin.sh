#!/bin/sh

[ $1 = update ] && { $install webmin; whitpail --msgbox "Webmin updated!" 8 32; exit; }
[ $1 = remove ] && { $remove webmin; whitpail --msgbox "Webmin removed!" 8 32; exit; }

# add repository to sources.list
cat >> /etc/apt/sources.list <<EOF

# webmin repository
deb http://download.webmin.com/download/repository sarge contrib
EOF

# add apt-key
[ $PKG = deb ] && wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add - && apt-get update
[ $PKG = rpm ] && rpm --import http://www.webmin.com/jcameron-key.asc | rpm --import -

$install webmin

# git clone https://github.com/qooob/authentic-theme

whiptail --msgbox "Webmin insmintalled!

Open http://$URL:10000 in your browser." 10 64
