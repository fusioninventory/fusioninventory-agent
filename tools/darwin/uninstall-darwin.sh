#!/bin/bash

PID=`ps -e | grep OCSNG | grep -v grep | awk '{print $2}'`
if [ "$PID" !=  "" ]; then
	echo 'killing process'
	sudo kill $PID
fi

FILES="/Library/LaunchAgents/org.ocsng.agent.plist /etc/ocsinventory-agent/ /var/lib/ocsinventory-agent/ /Applications/OCSNG.app /var/log/ocsng.log"

echo 'Stopping and unloading service'
launchctl stop org.ocsng.agent
launchctl unload /Library/LaunchAgents/org.ocsng.agent.plist

for FILE in $FILES; do
  echo 'removing '.$FILE
  rm -f -R $FILE
done

./dscl-remove-user.sh
