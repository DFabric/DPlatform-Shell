#!/bin/sh

# Install supervisor if not already present
hash systemctl 2>/dev/null || whiptail --msgbox "You need to use SystemD boot system" 8 48 exit

# Covert uppercase app name to lowercase service name
name=$(echo "$1" | tr '[:upper:]' '[:lower:]')

service_detection() {
  service_list=
  service_list="SystemD [status]boot-auto-start"

  # Parse line by line installed apps, and create en entry for each
  while read service
  do
    # Covert uppercase app name to lowercase service name
    service=$(echo "$service" | tr '[:upper:]' '[:lower:]')
    # Remove spaces and the service name
    service_list="$service_list $service [$(systemctl is-active $service)]$(systemctl is-enabled $service)"
  done < installed-apps
}

# Service's setup menu
service_setup(){

  restart=
  # Create entries in function of actual service status and configuration
  [ $(systemctl is-active $service_choice) = active ] && active_state=Stop && restart="Restart Restart_the_current_${service_choice}_service_process"
  [ $(systemctl is-active $service_choice) = inactive ] && active_state=Start
  [ $(systemctl is-enabled $service_choice) = enabled ] && enabled_state=Disable
  [ $(systemctl is-enabled $service_choice) = disabled ] && enabled_state=Enable

  whiptail --title "$service_choice service setup" --menu "
  $service_choice: $(systemctl is-active $service_choice)
  Auto-start at boot: $(systemctl is-enabled $service_choice)" 14 72 4 \
  $active_state "$active_state the current $service_choice service process" $restart \
  ${enabled_state}-boot-auto-start "$enabled_state the current $service_choice service process" \
  Status "Details about the current service status" \
  2> /tmp/temp
  read service < /tmp/temp
  case $service_choice in
    Stop) systemctl stop $service_choice; whiptail --msgbox "$service_choice stopped" 8 32;;
    Start) systemctl start $service_choice; whiptail --msgbox "$service_choice started" 8 32;;
    Restart) systemctl restart $service_choice; whiptail --msgbox "$service_choice restarted" 8 32;;
    Disable-boot-auto-start) systemctl disable $service_choice; whiptail --msgbox "$service_choice disabled" 8 32;;
    Enable-boot-auto-start) systemctl enable $service_choice; whiptail --msgbox "$service_choice enabled" 8 32;;
    Status) whiptail --msgbox "$(systemctl status $service_choice)" 11 64;;
  esac
}

# App Service Manager menu
if [ "$1" = "" ]
then
  service_detection
  while whiptail --title "App Service Manager" --menu "
  Select with Arrows <-v^-> and/or Tab <=>
  Mem RAM: $(free | awk 'FNR == 2 {print $4/1000}') MB used/$(free | awk 'FNR == 2 {print ($3+$4)/1000}') MB total" 16 72 6 \
  $service_list 2> /tmp/temp
  do
    cd $DIR
    read service_choice < /tmp/temp
    [ $service_choice = SystemD ] && whiptail --msgbox "$(systemctl status)" 11 64 || service_setup
    service_detection
  done

elif [ "$1" = remove ]
then
  rm /etc/systemd/system/$name.service

# Create systemd service
else
  cat > "/etc/systemd/system/$name.service" <<SERVICE
[Unit]
Description=$1
[Service]
Type=simple
WorkingDirectory=$3
ExecStart=$2
User=$USER
Restart=on-abort
[Install]
WantedBy=multi-user.target
SERVICE
  systemctl daemon-reload
  systemctl enable $name
  systemctl start $name
fi
