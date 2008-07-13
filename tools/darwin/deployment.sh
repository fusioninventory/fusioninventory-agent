#!/bin/bash

FILE=$1
TMPDIR=/tmp/ocsng

if [ ! -e $FILE ]; then
	echo "File: $FILE doesn't exist, exiting"
	exit 1;
fi

if [ `whoami` != 'root' ]; then
	echo 'You must be root [or sudo] to run this...'
	exit 1;
fi

echo "Deploying file: $FILE"

mkdir $TMPDIR
tar -zxvf $FILE -C $TMPDIR/
cd $TMPDIR
sudo sh installer-darwin.sh
cd ../
rm -R -f $TMPDIR

PID=`ps ax -e | grep OCSNG | grep -v grep | awk '{print $1}'`
if [ "$PID" !=  "" ]; then
        echo "Service launched under Pid: $PID"
	echo "Done"
	exit 0
else
	echo "Service failed to launch but was installed, check your logs"
fi
