#!/bin/bash
set -e

OCSNG_PATH="FusionInventory-Agent.app"
PATCHES_PATH="patches"
TOOLS_PATH="tools/macosx"
FINAL_PKG_NAME="unified_unix_agent-macosx"

ROOTDIR=$PWD/../..
if [ ! -x $ROOTDIR/inc ]; then
	echo "You're probably building from CVS, you're missing the "inc" directory in ../../"
	exit 1;
fi

if [ ! -x ./darwin-perl-lib ]; then
	if [ ! -e ./scripts/macosx-perl-lib-dep-snapshot.tar.gz ]; then
		echo "You're missing the darwin-perl-lib directory, did you run the create-darwin-perl-lib_fromCPAN.pl script?"
		exit 1;
	else
		echo 'extracting from snapshot perl-lib deps to ./'
		tar -zxvf ./scripts/macosx-perl-lib-dep-snapshot.tar.gz
	fi
fi

if [ -x $OCSNG_PATH ]; then
	echo "removing old $OCSNG_PATH"
        rm -R -f $OCSNG_PATH
fi

if [ -x package-root ]; then
	echo 'removing old package-root'
	rm -R -f package-root
fi

echo "Building OS X App"
cd ocsng_app-xcode/
xcodebuild
cp -R ./build/UninstalledProducts/$OCSNG_PATH ../
xcodebuild clean
cd ../
mkdir $OCSNG_PATH/Contents/Resources/lib

echo "Creating default config"

echo "server=http://inventory/ocsinventory" > ./agent.cfg
echo "tag=DEFAULT" >> ./agent.cfg
echo "logfile=/var/log/ocsng.log" >> ./agent.cfg
echo "delaytime=30" >> ./agent.cfg

echo 'Touching cacert.pem'
echo "Make sure you replace me with your real cacert.pem" > cacert.pem

echo 'creating package-root for building .pkg under'
mkdir -p ./package-root/Applications

echo 'removing non-MacOS/Generic backend modules'
cd $ROOTDIR/lib/FusionInventory/Agent/Task/Inventory/OS/
echo rm -R -f `ls -l | grep -v MacOS | grep -v Generic`
cd $ROOTDIR 

echo "Building Makefile.pl...."
cd $ROOTDIR 
perl Makefile.PL
make
cp -R blib/lib ./$TOOLS_PATH/$OCSNG_PATH/Contents/Resources
cp fusioninventory-agent ./$TOOLS_PATH/
make clean

echo 'patching main perl script for OS X'
cd ./$TOOLS_PATH/
cp fusioninventory-agent $OCSNG_PATH/Contents/Resources/

echo 'copying down darwin-dep libs'
cp -R darwin-perl-lib/ $OCSNG_PATH/Contents/Resources/lib/

echo 'copying .app to package-root'
cp -R $OCSNG_PATH ./package-root/Applications/

echo 'setting default permissions on ./package-root/Applications'
chown root:admin ./package-root/Applications
chmod 775 ./package-root/Applications

# package maker might spit out some permissions errors if the app or it's folders are on your system already, this is usually OK, read them to make sure
echo "building package"
echo rm -R -f ./FusionInventory-Agent.pkg
/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -build -proj FusionInventory-Agent.pmproj -p ./FusionInventory-Agent.pkg

FILES="fusioninventory-agent README INSTALL launchfiles FusionInventory-Agent.pkg scripts agent.cfg cacert.pem"

[ -d $FINAL_PKG_NAME ] && rm -rf $FINAL_PKG_NAME 
mkdir $FINAL_PKG_NAME
cp -R $FILES $FINAL_PKG_NAME/
zip -r $FINAL_PKG_NAME $FINAL_PKG_NAME/ -x \*CVS\* -x \*svn\* -x \*bzr\*
echo rm -R -f $FINAL_PKG_NAME
echo "done"
