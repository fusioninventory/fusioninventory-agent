#!/bin/bash

#
# Config
#

USERID=3995
GROUPID=3995

#
# /Config
#

echo "Creating Primary _ocsng Group: $GROUPID"

sudo dscl . -create /Groups/_ocsng
sudo dscl . -append /Groups/_ocsng RecordName ocsng
sudo dscl . -create /Groups/_ocsng PrimaryGroupID $GROUPID
sudo dscl . -create /Groups/_ocsng RealName "OCSNG Group"

echo "Creating Primary _ocsng User: $USERID"

sudo dscl . -create /Users _ocsng
sudo dscl . -append /Users/_ocsng RecordName ocsng
sudo dscl . -create /Users/_ocsng UniqueID $USERID
sudo dscl . -create /Users/_ocsng PrimaryGroupID $GROUPID
sudo dscl . -create /Users/_ocsng UserShell /usr/bin/false
sudo dscl . -create /Users/_ocsng RealName "OCSNG Daemon User"
sudo dscl . -create /Users/_ocsng NFSHomeDirectory /var/empty

echo "Adding _ocsng user to admin and daemon groups"

sudo dscl . -append /Groups/admin GroupMembership _ocsng
sudo dscl . -append /Groups/daemon GroupMembership _ocsng
