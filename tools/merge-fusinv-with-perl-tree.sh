#!/bin/sh

PERLVERSION="5.12.1"
set -e

TARBALL=$1

if [ -z $TARBALL ]; then
    echo "Merge the agent with a perl tarball generated with build-perl-tree.sh"
    echo "usage:"
    echo "$0 perl-tarball.tar"
    exit 1
fi

if [ ! -f $TARBALL ]; then
    echo "Can't find $TARBALL"
    exit 1
fi

if [ -d "fusioninventory-agent" ]; then
    echo "please remove fusioninventory-agent directory first"
    exit 1
fi

if [ -d "perl" ]; then
    echo "please remove perl directory first"
    exit 1
fi

mkdir fusioninventory-agent
tar xf $TARBALL
mv perl fusioninventory-agent

cat >> fusioninventory-agent/agent.sh << EOF
#!/bin/sh
# Try to detect lib directory with the XS files
# since we build with thread support, this should be, err
# hum, well "safe".
XSDIR=\`ls -d ./perl/lib/5.12.1/*-thread-*\`

export PERL5LIB="perl/lib/5.12.1:perl/lib/site_perl/5.12.1:\$XSDIR"
exec \$PWD/perl/bin/perl perl/bin/fusioninventory-agent --conf-file=./agent.cfg --basevardir=./var --html-dir=./share/html \$*
EOF
chmod +x fusioninventory-agent/agent.sh

cp ../etc/fusioninventory/agent.cfg fusioninventory-agent
cp ../fusioninventory-agent fusioninventory-agent/perl/bin
cp -r ../share fusioninventory-agent
cp -r ../lib/FusionInventory fusioninventory-agent/perl/lib/site_perl/$PERLVERSION/
