#!/bin/bash

#install stuff
what=${PWD##*/}   
extension=
what2=safepush  
extension2=.php
#peut être extension vide

echo "Set executable..."
chmod +x $what$extension
#echo "lien symbolique vers usr bin"
sudo ln -s "$PWD/$what$extension" /usr/bin/$what
echo "done."

cd ../../safepush
echo "Installing safepush, \n Set executable..."
chmod +x $what2$extension2
#echo "lien symbolique vers usr bin"
sudo ln -s "$PWD/$what2$extension2" /usr/bin/$what2
echo "done."

#cd back to where we was
