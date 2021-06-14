#!/bin/bash

#install stuff
what=${PWD##*/}   
extension=
what2=safepush  
extension2=.php
what3=safepull
extension3=.php
#peut être extension vide 
 
echo "killing running instances"
killall $what

echo "remove symbolic link from usr bin"
sudo rm /usr/bin/$what

echo "done."


echo "Uninstall safepush"



 
echo "killing running instances"
killall $what2

echo "remove symbolic link from usr bin"
sudo rm /usr/bin/$what2

echo "done."


echo "killing running instances"
killall $what3

echo "remove symbolic link from usr bin"
sudo rm /usr/bin/$what3

echo "done."