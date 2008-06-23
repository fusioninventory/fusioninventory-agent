#!/bin/bash

echo 'determining OS Version'
OSVER=`uname -r`
echo "OS: $OSVER"

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
sudo mkdir -p $TPATH
sudo chown 3995:admin $TPATH

TPATH="/var/log/ocsng.log"
sudo touch $TPATH
sudo chown root:admin $TPATH
sudo chmod 660 $TPATH

if [ "$OSVER" == "7.9.0" ]; then
	echo "Found Jaguar OS, using 10.3 StartupItems setup"
	TPATH="/System/Library/StartupItems"
	sudo cp -R ./jag-startup/OCSInventory $TPATH/
	sudo chown -R root:wheel $TPATH/OCSInventory
	sudo chmod 755 $TPATH/OCSInventory
	sudo chmod 644 $TPATH/OCSInventory/StartupParameters.plist
	sudo chmod 755 $TPATH/OCSInventory/OCSInventory

	echo 'Starting Service using Sudo'
	sudo /System/Library/StartupItems/OCSInventory/OCSInventory start
else
	echo "Found Tiger or newer OS, using LaunchAgent plists"
	TPATH="/Library/LaunchAgents/"
	sudo cp org.ocsng.agent.plist $TPATH
	sudo chown root:wheel $TPATH/org.ocsng.agent.plist
	sudo chmod 644 $TPATH/org.ocsng.agent.plist

	echo 'Loading Service'
	sudo launchctl load $TPATH

	echo 'Starting Service'
	sudo launchctl start org.ocsng.agent
fi

echo 'done'
