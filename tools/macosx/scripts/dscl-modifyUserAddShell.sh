#!/bin/bash

echo "USE THIS SCRIPT AT YOUR OWN RISK!!!"
echo "remove these lines to use"
exit;

CMD=md5

if [ -x /usr/local/bin/shasum ]; then
	echo 'using shasum -a 384 to generate random password instead of md5'
	CMD='shasum -a 384'
fi

PASSWD=`head -n 4096 /dev/random | $CMD`

echo 'hijacking system log so password isn't stored there'
sudo mv /var/log/system.log /var/log/system.log.orig
sudo launchctl stop com.apple.syslogd # it will restart on it's own

echo 'adding bash as the shell with a random password'
sudo dscl . -create /Users/_ocsng UserShell "/bin/bash"
sudo dscl . -passwd /Users/_ocsng $PASSWD

echo 'restoring system.log'
sudo mv -f /var/log/system.log.orig /var/log/system.log
sudo launchctl stop com.apple.syslogd # it will restart on it's own
