#! /bin/bash
# This is an example script for the byHand software collect method
#
# You can create your own script to detect the installed software
# and install them in /etc/ocsinventory/softwares
#
#ligne=$(ls --version| head -n 1)
#
#soft=$(echo $ligne | cut -f1 -d'('| sed 's/ //')
#vendor=$(echo $ligne | cut -f2 -d'('| cut -f1 -d')')
#version=$(echo $ligne | cut -f2 -d'('| cut -f2 -d')'|sed 's/ //')
#
#echo "$vendor#$soft#$version#simple test"
#
#
