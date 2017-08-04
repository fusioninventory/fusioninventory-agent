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

# Prepare source
[ -e Makefile ] && { perl Makefile.PL ; make purge ; }
rm -f MANIFEST META.yml
perl Makefile.PL
make manifest

make dist

# Extract version from Makefile
VERSION=$( egrep '^VERSION = ' Makefile | cut -d'=' -f2 | tr -d ' ' )

# Move package to the expected place
rm -f ../fusioninventory-agent_$VERSION*
mv -vf FusionInventory-Agent-$VERSION.tar.gz ../fusioninventory-agent_$VERSION.orig.tar.gz

set +e
echo "Building Debian package..."
pdebuild --use-pdebuild-internal

dh_clean
