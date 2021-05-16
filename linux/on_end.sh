#!/bin/bash
# This script will run on safecurl end, args : success, curlAct 

success="$1"
curlAct="$2"

iconok="/usr/share/themes/Breath/assets/check-checked-hover@2.png"
iconfail="/usr/share/themes/Breath/assets/titlebutton-close-active-backdrop@2.png"

#aplay "/usr/lib/libreoffice/share/gallery/sounds/left.wav";
   notify-send "SafeCurl $curlAct SUCCEEDED !";
notify-send -u critical -i "notification-message-IM" 'Boss !!' 'Am done with the execution'

if [ $success == "True" ];then
   #echo "succedded $curlAct">/home/boony/safecurl.txt
   #aplay "/usr/lib/libreoffice/share/gallery/sounds/untie.wav";
   #aplay "/usr/lib/libreoffice/share/gallery/sounds/left.wav";
   notify-send "$title - $curlAct" "SUCCEEDED !" -i "$iconok";
else
   #echo "operation $curlAct failed">/home/boony/safecurl.txt
   notify-send "$title - $curlAct" "FAILED !" -i "$iconfail";
   aplay "/usr/lib/libreoffice/share/gallery/sounds/left.wav";   
fi

