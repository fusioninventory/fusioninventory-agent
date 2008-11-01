#!/bin/bash

FILES="OCSNG.pkg cacert.pem launchfiles modules.conf scripts"
EXCLUDE="--exclude=*CVS* --exclude=*.svn/* --exclude=*DS_Store*"
DEPLOYMENT_DIR="unified_unix_agent-macosx"
PKG_NAME="unified_unix_agent-macosx"

if [ ! -d ./$DEPLOYMENT_DIR ]; then
	echo "making deployment directory $DEPLOYMENT_DIR"
	mkdir $DEPLOYMENT_DIR
fi

echo "copying the files needed to our working dir: $DEPLOYMENT_DIR"
for FILE in $FILES; do
	cp -R $FILE $DEPLOYMENT_DIR
done

echo "tar'ing the file..."
tar $EXCLUDE -zcf $PKG_NAME.tar.gz $DEPLOYMENT_DIR

echo "generating the installer_wrapper.sh script"
# this is where we create the install_wrapper script
# if you modify, besure to 'escape' (using a '\') any variables

cat > install_wrapper.sh << EOF
#!/bin/bash

VERSION=`perl scripts/extract_version.pl`

function usage {
        echo "This program does..."
        echo "usage: \$0 [-s] [-t]"
        echo ""
        echo "  -s      : SERVER address (in the format: 'http://example.com/ocsreports')"
        echo "  -t      : TAG (defaut: DEFAULT)"
        echo ""
        echo "  example: \$0 -s http://inventory.example.com/ocsreports -t NEWYORK"
        echo ""
}

SERVER="ocsinventory"
TAG="DEFAULT"
LOGFILE="/var/log/ocsng.log"
DELAY="120"
TMPDIR="/tmp"

while getopts ":s:t:hl:d:T:" Option
do
	case \$Option in
		s) SERVER=\$OPTARG;;
		t) TAG=\$OPTARG;;
		d) DELAY=\$OPTARG;;
		l) LOGFILE=\$OPTARG;;
		T) TMPDIR=\$OPTARG;;
		h) usage; exit;
	esac
done

dir=\`dirname \$0\`;
if [ x\$dir = "x." ]
then
        dir=\`pwd\`
fi
base=\`basename \$0\`;

(cd \$TMPDIR; uudecode -p \$dir/\$base|tar xzfv -)
cd \$TMPDIR/$DEPLOYMENT_DIR;
echo "delaytime=\$DELAY" > ocsinventory-agent.cfg
echo "logfile=\$LOGFILE" >> ocsinventory-agent.cfg
echo "server=\$SERVER" >> ocsinventory-agent.cfg
echo "tag=\$TAG" >> ocsinventory-agent.cfg
sh scripts/installer.sh
exit 0;
EOF

# end of generated script for installer_wrapper.sh

echo "Appending $PKG_NAME.tar.gz to the install_wrapper.sh"
uuencode $PKG_NAME.tar.gz $PKG_NAME.tar.gz >> install_wrapper.sh

echo "Cleaning up..."
rm -R -f $DEPLOYMENT_DIR
rm $PKG_NAME.tar.gz
echo "Done, you may now use the installer_wrapper.sh to deploy the agent"
