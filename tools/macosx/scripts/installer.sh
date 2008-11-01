#!/bin/bash

PREFIX=./

echo 'determining OS Version'
OSVER=`uname -r`
echo "OS: $OSVER"

echo 'Running user creation script'
$PREFIX/scripts/dscl-adduser.sh

# what uid/gid did we end up going with?
USERID=`sudo dscl . -read /Users/_ocsng UniqueID | awk -F' ' '{print $2}'`
GROUPID=`sudo dscl . -read /Groups/_ocsng PrimaryGroupID | awk -F' ' '{print $2}'`

echo "Using UserID: $USERID"
echo "Using GroupID: $GROUPID"

echo 'Running package installer'
sudo installer -pkg OCSNG.pkg -target /

INSTALL_PATH="/Applications/OCSNG.app"
echo "Copying uninstall script to $INSTALL_PATH"
sudo chmod 700 $PREFIX/scripts/uninstaller.sh
sudo cp $PREFIX/scripts/uninstaller.sh $INSTALL_PATH/Contents/Resources/
sudo chmod -R o-rwx,u-w $INSTALL_PATH
sudo chown -R $USERID:$GROUPID $INSTALL_PATH

TPATH="/etc/ocsinventory-agent"
sudo mkdir $TPATH/
sudo chown root:admin $TPATH/
sudo chmod 770 $TPATH/
sudo cp $PREFIX/ocsinventory-agent.cfg $TPATH/
sudo cp $PREFIX/modules.conf $TPATH/

TPATH="/var/lib/ocsinventory-agent"
sudo mkdir -p $TPATH
sudo chown $USERID:admin $TPATH

if [ -e $PREFIX/cacert.pem ]; then
	echo "copying cacert.pem to $TPATH/"
	sudo cp $PREFIX/cacert.pem $TPATH/
	sudo chown $USERID:admin $TPATH/cacert.pem
	sudo cp $PREFIX/cacert.pem $TPATH/
fi

TPATH="/var/log/ocsng.log"
sudo touch $TPATH
sudo chown root:admin $TPATH
sudo chmod 660 $TPATH

if [ "$OSVER" == "7.9.0" ]; then
	echo "Found Jaguar OS, using 10.3 StartupItems setup"
	TPATH="/System/Library/StartupItems"
	sudo cp -R $PREFIX/launchfiles/10_3_9-startup/OCSInventory $TPATH/
	sudo chown -R root:wheel $TPATH/OCSInventory
	sudo chmod 755 $TPATH/OCSInventory
	sudo chmod 644 $TPATH/OCSInventory/StartupParameters.plist
	sudo chmod 755 $TPATH/OCSInventory/OCSInventory

	echo 'Starting Service using Sudo'
	sudo /System/Library/StartupItems/OCSInventory/OCSInventory start
else
	echo "Found Tiger or newer OS, using LaunchAgent plists"
	TPATH="/Library/LaunchAgents/"
	sudo cp $PREFIX/launchfiles/org.ocsng.agent.plist $TPATH
	sudo chown root:wheel $TPATH/org.ocsng.agent.plist
	sudo chmod 644 $TPATH/org.ocsng.agent.plist

	echo 'Loading Service'
	sudo launchctl load $TPATH/org.ocsng.agent.plist

	echo 'Starting Service'
	sudo launchctl start org.ocsng.agent
fi

echo 'done'
exit 0 
