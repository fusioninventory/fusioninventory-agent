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

# Prepare source archive removing debian forlder
VERSION=$( head -1 debian/changelog | sed -re 's/^.*\((.*:)?//' -e 's/(-.*)?\).*//' )
git archive --format=tar --prefix=fusioninventory-agent.orig/ HEAD | \
	tar --delete 'fusioninventory-agent.orig/debian/' | \
	gzip -9n >../fusioninventory-agent_$VERSION.orig.tar.gz

pdebuild --use-pdebuild-internal

dh_clean
