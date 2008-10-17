#!/bin/bash

echo "USE AT OWN RISK!"
echo "remove theses lines to execute"
exit;

sudo cp /etc/sudoers /tmp/sudoers.new
sudo chmod o+w /tmp/sudoers.new
sudo echo "" >> /tmp/sudoers.new
sudo echo "# Same thing without a password for _ocsng and installer" >> /tmp/sudoers.new
sudo echo "_ocsng        localhost = NOPASSWD: /usr/sbin/installer" >> /tmp/sudoers.new

echo 'checking file'
RET=`sudo visudo -c -f /tmp/sudoers.new`

if [ "$RET" == '/tmp/sudoers.new file parsed OK' ]; then
	echo "File is OK, swapping out"
else
	echo "File not ok, bailing!"
	exit -1;
fi
exit;

sudo cp /etc/sudoers /etc/sudoers.pre-ocsng
chmod 440 /tmp/sudoers.new
sudo mv /tmp/sudoers.new /etc/sudoers
sudo chown root:wheel /etc/sudoers
