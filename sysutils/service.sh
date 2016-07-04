#!/bin/sh

# Install supervisor if not already present
hash systemctl 2>/dev/null || whiptail --msgbox "You need to use SystemD boot system" 8 48 exit

service_detection() {
  service_list=
  service_list="SystemD [status]auto-start-at-boot"

  # Parse line by line dp.cfg, and create en entry for each
  while read service ;do
    # Covert uppercase app name to lowercase service name
    service=$(echo "$service" | tr '[:upper:]' '[:lower:]')

    # Correct the service name of the app
    [ $service = mumble ] && service_list="$service_list mumble-server ${service_description#*=}[$(systemctl is-active mumble-server)]$(systemctl is-enabled mumble-server)"
    [ $service = deluge ] && service=deluged
    [ $service = mongod ] && service=mongod
    # Only create an entry for existing services
    if [ -f /etc/systemd/system/$service.service ] || [ -f /lib/systemd/system/$service.service ] ;then
      # Concatenate the service into a list
      service_list="$service_list $service ${service_description#*=}[$(systemctl is-active $service)]$(systemctl is-enabled $service)"
    fi
    # Add related services to the app
    [ $service = seafile ] && service_list="$service_list seahub [$(systemctl is-active seahub)]$(systemctl is-enabled seahub)"
    [ $service = deluge ] && service_list="$service_list deluge-web [$(systemctl is-active deluge-web)]$(systemctl is-enabled deluge-web)"
  done < dp.cfg
}

# Service's setup menu
service_setup(){

  restart=
  # Create entries in function of actual service status and configuration
  [ $(systemctl is-active $service_choice) = inactive ] && state_action=Start || state_action=Stop && restart="Restart Restart_the_current_${service_choice}_service_process"
  [ $(systemctl is-enabled $service_choice) = enabled ] && enabled_state=Disable
  [ $(systemctl is-enabled $service_choice) = disabled ] && enabled_state=Enable

  service_action=$(whiptail --title "$service_choice service setup" --menu " $(systemctl show $service_choice -p Description)
  Active status: $(systemctl is-active $service_choice)
  Auto-start at boot: $(systemctl is-enabled $service_choice)" 14 72 4 \
  $state_action "$state_action the current $service_choice service process" $restart \
  ${enabled_state}_auto-start-at-boot "$enabled_state the current $service_choice service process" \
  Status "Details about the current service status" \
  3>&1 1>&2 2>&3)
  case $service_action in
    Stop) systemctl stop $service_choice; whiptail --msgbox "$service_choice stopped" 8 32;;
    Start) systemctl start $service_choice; whiptail --msgbox "$service_choice started" 8 32;;
    Restart) systemctl restart $service_choice; whiptail --msgbox "$service_choice restarted" 8 32;;
    Disable_auto-start-at-boot) systemctl disable $service_choice; whiptail --msgbox "$service_choice disabled" 8 32;;
    Enable_auto-start-at-boot) systemctl enable $service_choice; whiptail --msgbox "$service_choice enabled" 8 32;;
    Status) whiptail --msgbox "$(systemctl status $service_choice)" 11 64;;
  esac
}

# Main App Service Manager menu
if [ "$1" = "" ] ;then
  while
  service_detection
  used_memory=$(free -m | awk '/Mem/ {printf "%.2g\n", (($3+$5)/1000)}')
  total_memory=$(free -m | awk '/Mem/ {printf "%.2g\n", ($2/1000)}')
  service_choice=$(whiptail --title "App Service Manager" --menu "
  Select with Arrows <-v-> and/or Tab <=>
  Memory usage: $used_memory GiB used / $total_memory GiB total" 16 72 6 \
  $service_list 3>&1 1>&2 2>&3) ;do
    cd $DIR
    [ $service_choice = SystemD ]; whiptail --msgbox "$(systemctl status)" 11 64 || service_setup
    service_detection
  done

elif [ "$1" = remove ] ;then
  # Convert uppercase app name to lowercase service name
  name=$(echo "$2" | tr '[:upper:]' '[:lower:]')
  systemctl stop $name
  systemctl disable $name
  rm /etc/systemd/system/$name.service
  systemctl daemon-reload
  systemctl reset-failed

# Create systemd service
else
  # Convert uppercase app name to lowercase service name
  name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  [ "$4" != "" ] && user=$4 || user=$USER
  cat > "/etc/systemd/system/$name.service" <<EOF
[Unit]
Description=$1 Server
After=network.target
[Service]
Type=simple
WorkingDirectory=$3
ExecStart=$2
User=$user
Restart=always
[Install]
WantedBy=multi-user.target
EOF
  # Start the service and enable it to start up on boot
  systemctl start $name
  systemctl enable $name
fi
