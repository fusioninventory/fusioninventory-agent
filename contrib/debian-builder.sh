#! /bin/bash

set -e

# pbuilder is mandatory
if [ -z "$( which pbuilder 2>&1 )" ]; then
	echo "You need pbuilder software, please install it before continuing" >&2
	exit 1
fi

# sudo must be enabled
if ! sudo /bin/true ; then
	echo "You need to enable sudo" >&2
	exit 1
fi

# Initialize pbuilder environment
if [ ! -e "/var/cache/pbuilder/base.tgz" ]; then
	sudo pbuilder create
fi

# Check options
while [ -n "$1" ]
do
	case "$1" in
		--update)
			sudo pbuilder --update
			;;
	esac
	shift
done

# Prepare source archive
VERSION=$( head -1 debian/changelog | sed -re 's/^.*\((.*:)?//' -e 's/(-.*)?\).*//' )
if [ ! -e "../fusioninventory-agent_$VERSION.orig.tar.gz" ]; then
	git archive --format=tar.gz -9 --prefix=fusioninventory-agent.orig/ \
		-o ../fusioninventory-agent_$VERSION.orig.tar.gz HEAD
fi

pdebuild --use-pdebuild-internal

dh_clean
