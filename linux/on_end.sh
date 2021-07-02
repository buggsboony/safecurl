#!/bin/bash
# This script will run on safecurl end, args : success: True or False, curlAct: Download or Upload
# This script will run on safecurl end, args : success, curlAct 

success="$1"
curlAct="$2"
baseName=$(basename "$3")


title="SafeCurl"
iconok="/usr/share/themes/Breath/assets/check-checked-hover@2.png"
iconfail="/usr/share/themes/Breath/assets/titlebutton-close-active-backdrop@2.png"

#aplay "/usr/lib/libreoffice/share/gallery/sounds/left.wav";
#   notify-send "SafeCurl $curlAct SUCCEEDED !";
#notify-send -u critical -i "notification-message-IM" 'Boss !!' 'Am done with the execution'

if [ $success == "True" ];then
   #echo "succedded $curlAct">/home/boony/safecurl.txt
   #aplay "/usr/lib/libreoffice/share/gallery/sounds/untie.wav";
   #aplay "/usr/lib/libreoffice/share/gallery/sounds/left.wav";
   notify-send "$title - $curlAct" "SUCCEEDED $baseName !" -i "$iconok" --expire-time 500;
else
   #echo "operation $curlAct failed">/home/boony/safecurl.txt
   notify-send "$title - $curlAct" "FAILED $baseName !" --icon "$iconfail" --expire-time 50000
      aplay "/usr/lib/libreoffice/share/gallery/sounds/left.wav"
fi

