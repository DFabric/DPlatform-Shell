#!/bin/sh

whiptail --yesno "Yes to install from binary (only for amd64 and i386)

No if your prefer to build from sources (Can be long)" 12 48
case $? in

  # Download Binary
  0) mkdir wide-1.4.0
  cd wide-1.4.0
  if [ $ARCH = amd64 ]
    then wget http://lx.cdn.baidupcs.com/file/b30e4aef9fe789867b59ca7bb0dc002e?bkt=p2-nb-75&xcode=d12e795f9be7e60ef824d3885ec3c76f3c85c1060b1737f0837047dfb5e85c39&fid=3255126224-250528-1021217197053130&time=1447188723&sign=FDTAXGERBH-DCb740ccc5511e5e8fedcff06b081203-l2MBQ0YEiTDAP0mhFqfF5IN21%2FQ%3D&to=cb&fm=Nin,B,M,ny&sta_dx=11&sta_cs=2&sta_ft=gz&sta_ct=5&fm2=Ningbo,B,M,ny&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=1400b30e4aef9fe789867b59ca7bb0dc002e628e22ad000000a9a83e&expires=8h&rt=sh&r=593882646&mlogid=7287250582746414964&vuk=-&vbdid=860392109&fin=wide-1.4.0-linux-amd64.tar.gz&fn=wide-1.4.0-linux-amd64.tar.gz&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=7287250582746414964&dp-callid=0.1.1
  elif [ $ARCH = 86 ]
    then wget http://qd2.cache.baidupcs.com/file/df0884d6efcf70ffc7ac449dbce4e0a9?bkt=p2-nb-75&xcode=d12e795f9be7e60e39354dd100e6ba6233c2bbcfe1c34adc&fid=3255126224-250528-948651857737407&time=1447188788&sign=FDTAXGERBH-DCb740ccc5511e5e8fedcff06b081203-2iFbrr%2FQNooANCM0%2BPji3W%2F5Sk0%3D&to=qc2&fm=Nin,B,M,ny&sta_dx=10&sta_cs=0&sta_ft=gz&sta_ct=5&fm2=Ningbo,B,M,ny&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=1400df0884d6efcf70ffc7ac449dbce4e0a92911d6580000009ff117&expires=8h&rt=sh&r=172419375&mlogid=7287267957411069572&vuk=-&vbdid=860392109&fin=wide-1.4.0-linux-386.tar.gz&fn=wide-1.4.0-linux-386.tar.gz&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=7287267957411069572&dp-callid=0.1.1
  fi
  tar -zxvf wide-1.4.0-*.tar.gz
  rm wide-1.4.0-*.tar.gz;;

  # Build Wide
  1) $install git golang
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

whiptail --msgbox "Wide successfully installed!

Open browser: http://$IP:7070" 12 48
