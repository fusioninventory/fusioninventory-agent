#!/bin/bash

echo 'Removing _ocsng from admin and daemon group'

sudo dscl . -delete /Groups/admin GroupMembership _ocsng
sudo dscl . -delete /Groups/daemon GroupMembership _ocsng

echo 'Removing _ocsng user'

sudo dscl . -delete /Users/_ocsng

echo 'Removing _ocsng group'

sudo dscl . -delete /Groups/_ocsng
