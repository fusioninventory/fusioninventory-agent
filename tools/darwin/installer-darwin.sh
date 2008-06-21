#!/bin/bash

echo 'Running user creation script'

./dscl-adduser.sh

echo 'Running package installer'
sudo installer -pkg OCSNG.pkg -target /

TPATH="/etc/ocsinventory-agent"
sudo mkdir $TPATH/
sudo chown root:admin $TPATH/
sudo chmod 770 $TPATH/
sudo cp ./ocsinventory-agent.cfg $TPATH/

TPATH="/var/lib/ocsinventory-agent"
sudo mkdir $TPATH
sudo chown 3995:admin $TPATH

TPATH="/var/log/ocsng.log"
sudo touch $TPATH
sudo chown root:admin $TPATH
sudo chmod 660 $TPATH

TPATH="/Library/LaunchAgents/"
sudo cp org.ocsng.agent.plist $TPATH
sudo chown root:wheel $TPATH/org.ocsng.agent.plist
sudo chmod 644 $TPATH/org.ocsng.agent.plist

echo 'Loading Service'
sudo launchctl load $TPATH

echo 'Starting Service'
sudo launchctl start org.ocsng.agent

echo 'done'
