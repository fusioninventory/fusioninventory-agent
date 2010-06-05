#!/bin/sh

PERLVERSION="5.12.1"
set -e

installModulesFromGit () {
    if [ ! -d $TMP/git ]; then
        mkdir $TMP/git

        for module in $MODULES; do
            echo git clone $GITBASEDIR/fusioninventory-agent-task-$module.git
            git clone $GITBASEDIR/fusioninventory-agent-task-$module.git $TMP/git/$module
        done
    fi

    currentDir=$PWD
    for module in $MODULES; do
        echo $TMP/git/$module
        cd $TMP/git/$module
        git pull
        cd $currentDir

        cp -rv $TMP/git/$module/lib/FusionInventory/Agent/Task/* fusioninventory-agent/perl/lib/site_perl/$PERLVERSION/FusionInventory/Agent/Task 
    done


}


TARBALL=$1
RELEASE=$2

MODULES="ocsdeploy snmpquery netdiscovery"
GITBASEDIR="https://github.com/fusinv"
OS=`basename $TARBALL|sed 's,.tar$,,'`
DATE=`date +%Y%m%d`
GITCOMMIT=`git log --oneline -1|awk '{print $1}'`
TMP="tmp"

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

# Purge some files we don't need
chmod -R u+w *
find . -name '*.pod' -delete
rm -r fusioninventory-agent/perl/man
mv fusioninventory-agent/perl/bin fusioninventory-agent/perl/bin.tmp
mkdir fusioninventory-agent/perl/bin
mv fusioninventory-agent/perl/bin.tmp/perl fusioninventory-agent/perl/bin
rm -r fusioninventory-agent/perl/bin.tmp

# Install the agent.sh
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

installModulesFromGit

FINALNAME=fusioninventory-agent_$OS
if [ ! -z $RELEASE ]; then
    FINALNAME=$FINALNAME'_'$RELEASE
else
    FINALNAME=$FINALNAME'_dev-'$DATE
    if [ ! -z $GITCOMMIT ]; then
        FINALNAME=$FINALNAME"-git"$GITCOMMIT
    fi
    echo $FINALNAME
fi
mv fusioninventory-agent $FINALNAME
tar czf $FINALNAME.tar.gz $FINALNAME
