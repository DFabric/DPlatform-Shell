#!/bin/sh

# Install supervisor if not already present
hash systemctl 2>/dev/null || whiptail --msgbox "You need to use SystemD boot system" 8 48 exit

# Covert uppercase app name to lowercase service name
name=$(echo "$1" | tr '[:upper:]' '[:lower:]')

service_detection() {
  cd/lib/systemd/system
  service_list=
  service_list="SystemD GlobalStatus"
  service_choice="SystemD) whiptail --msgbox "$(systemctl status)" 11 64;; "
  while read service
	do
    service=$(echo "$service" | tr '[:upper:]' '[:lower:]')
		# Remove .conf
		service=${service%????????}
		# Remove spaces and the service name
		service_list="$service_list $service $(systemctl is-active $service)"
	done < $(cat installed-aps)
}

# App Service Manager menu
if [ "$1" = "" ]
then
  service_detection
  while whiptail --title "App Service Manager" --menu "
  Select with Arrows <-v^-> and/or Tab <=>
  Mem RAM: $(free | awk 'FNR == 2 {print $4/1000}') MB used/$(free | awk 'FNR == 2 {print ($3+$4)/1000}') MB total" 20 80 10 \
  $service_list 2> /tmp/temp
  do
    cd $DIR
    read CHOICE < /tmp/temp
    case $(systemctl is-active $service) in
      active) systemctl stop $CHOICE; whiptail --msgbox "$CHOICE stopped" 8 32;;
      inactive) systemctl start $CHOICE; whiptail --msgbox "$CHOICE started" 8 32;;
    esac
    service_detection
  done

elif [ "$1" = remove ]
then
  rm /lib/systemd/system/$name.service

# Create systemd service
else
  cat > "/lib/systemd/system/$name.service" <<SERVICE
[Unit]
Description=$1
[Service]
Type=forking
User=$user
ExecStart=$2
ExecStop=$4
WorkingDirectory=$3
Restart=on-abort
[Install]
WantedBy=multi-user.target
SERVICE
systemctl daemon-reload
fi
