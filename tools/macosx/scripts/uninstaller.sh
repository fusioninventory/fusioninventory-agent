#!/bin/bash

OSVER=`uname -r`
echo "OSVer is $OSVER"

PID=`ps ax -e | grep OCSNG | grep -v grep | grep -v $0 | awk '{print $1}'`
if [ "$PID" !=  "" ]; then
	echo "killing process: $PID"
	sudo kill $PID
fi

FILES="/Library/Receipts/OCSNG* /etc/ocsinventory-agent/ /var/lib/ocsinventory-agent/ /Applications/OCSNG.app /var/log/ocsng.log"

if [ "$OSVER" == "7.9.0" ]; then
	FILES="$FILES /Library/StartupItems/OCSInventory"
else
	FILES="$FILES /Library/LaunchAgents/org.ocsng.agent.plist"

	echo 'Stopping and unloading service'
	launchctl stop org.ocsng.agent
	launchctl unload /Library/LaunchAgents/org.ocsng.agent.plist
fi

for FILE in $FILES; do
  echo 'removing '.$FILE
  rm -f -R $FILE
done

if [ -e ./dscl-remove-user.sh ]; then
  	sudo ./dscl-remove-user.sh
else
  	echo 'Removing _ocsng from admin and daemon group'

	sudo dscl . -delete /Groups/admin GroupMembership _ocsng
	sudo dscl . -delete /Groups/daemon GroupMembership _ocsng

	echo 'Removing _ocsng user'

	sudo dscl . -delete /Users/_ocsng

	echo 'Removing _ocsng group'

	sudo dscl . -delete /Groups/_ocsng
fi
