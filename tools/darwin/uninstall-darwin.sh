#!/bin/bash

OSVER=`uname -r`
echo "OSVer is $OSVER"

PID=`ps ax -e | grep OCSNG | grep -v grep | awk '{print $1}'`
if [ "$PID" !=  "" ]; then
	echo "killing process: $PID"
	sudo kill $PID
fi

FILES="/Library/Receipts/OCSNG.pkg/ /etc/ocsinventory-agent/ /var/lib/ocsinventory-agent/ /Applications/OCSNG.app /var/log/ocsng.log"

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

./dscl-remove-user.sh
