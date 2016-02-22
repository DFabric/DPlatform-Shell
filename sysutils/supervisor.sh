#!/bin/sh

process_detection() {
  cd /etc/supervisor/conf.d
  process_list=
  process_list="Supervisor GlobalStatus"
  process_choice="Supervisor) whiptail --msgbox "$(supervisorctl status)" 16 16;; "
  for process in *.conf
	do
		# Remove .conf
		process=${process%?????}
		process_activity=$(supervisorctl status $process)
		# Remove spaces and the process name
		process_activity=$(echo "$process_activity" | sed -r "s/$process//g;s/[ ]+/_/g")
		process_list="$process_list $process $process_activity"
	done
}

# App Service Manager menu
if [ "$1" = "" ]
then
  process_detection
  while whiptail --title "App Service Manager" --menu "
  Select with Arrows <-v^-> and/or Tab <=>
  Mem RAM: $(free | awk 'FNR == 2 {print $4/1000}') MB used/$(free | awk 'FNR == 2 {print ($3+$4)/1000}') MB" 20 80 10 \
  $process_list 2> /tmp/temp
  do
  		cd $DIR
  		read CHOICE < /tmp/temp
  		case $CHOICE in
  			$process)
          case $process_activity in
            *RUNNING*) supervisorctl stop $process; whiptail --msgbox "$process stopped" 16 16;;
            *STOPPED*) supervisorctl start $process; whiptail --msgbox "$process started" 16 16;;
          esac;;
  		esac
      supervisorctl reread
      supervisorctl update
      process_detection
  done
# Create supervisor service
else
  hash supervisorctl 2>/dev/null || $install supervisor

  cat > /etc/supervisor/conf.d/$1.conf <<EOF
[program:$1]
command=$2
directory=$3
autostart=true
autorestart=unexpected
stderr_logfile=/var/log/$1.err.log
stdout_logfile=/var/log/$1.out.log
EOF
  supervisorctl reread
  supervisorctl update
fi
