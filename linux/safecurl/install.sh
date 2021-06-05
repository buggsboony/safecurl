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

cd ../../safepush
echo "Installing safepush, ($path2)\n Set executable..."
chmod +x $path2/$what2$extension2
#echo "lien symbolique vers usr bin"
sudo ln -s "$path2/$what2$extension2" /usr/bin/$what2
echo "done."

#cd back to where we was
