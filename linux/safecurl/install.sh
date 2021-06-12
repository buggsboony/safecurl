#!/bin/bash

#install stuff
what=${PWD##*/}   
extension=
what2=safepush  
extension2=.php
what3=safepull
extension3=.php
#peut être extension vide

echo "Set executable..."
chmod +x $what$extension
#echo "lien symbolique vers usr bin"
sudo ln -s "$PWD/$what$extension" /usr/bin/$what
echo "done."

cd ../../safepush
echo "Installing safepush, Set executable..."
chmod +x $what2$extension2
#echo "lien symbolique vers usr bin"
sudo ln -s "$PWD/$what2$extension2" /usr/bin/$what2
echo "done."

echo "Installing safepull, Set executable..."
chmod +x $what3$extension3
#echo "lien symbolique vers usr bin"
sudo ln -s "$PWD/$what3$extension3" /usr/bin/$what3
echo "done."

#cd back to where we was
