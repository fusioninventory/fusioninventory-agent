#!/bin/bash

echo 'Running user creation script'

./dscl-adduser.sh

echo 'Running package installer'

sudo installer -pkg OCSNG.pkg -target /

echo 'Loading Service'

sudo launchctl load /Library/LaunchDaemons/org.ocsng.agent.plist

echo 'Starting Service'

sudo launchctl start org.ocsng.agent

echo 'done'
