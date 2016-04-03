#!/bin/sh

[ $1 = update ] && whiptail --msgbox "Not availabe yet!" 8 32 && break
[ $1 = remove ] && whiptail --msgbox "Not availabe yet!" 8 32 && break

# Contribution welcome :)

whiptail --msgbox "WordPress installed!

Open http://$URL in your browser!" 10 64
