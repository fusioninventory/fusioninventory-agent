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

rm -f MANIFEST
for dsc in *.dsc
do
	rm -f ${dsc%.dsc}.tar.gz $dsc
done

perl Makefile.PL

read var equal VERSION <<<$( egrep '^VERSION =' Makefile | head -1 )

DISTDIR="fusioninventory-agent-$VERSION"

make manifest
make distdir DISTVNAME="$DISTDIR"

cp -a contrib/debian "$DISTDIR"

cd "$DISTDIR"

pdebuild --use-pdebuild-internal
