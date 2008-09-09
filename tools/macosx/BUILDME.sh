#!/bin/bash

OCSNG_PATH="OCSNG.app"
PATCHES_PATH="patches"
TOOLS_PATH="tools/macosx"

if [ ! -x ../../inc ]; then
	echo "You're probably building from CVS, you're missing the "inc" directory in ../../"
	exit 1;
fi

if [ ! -x ./darwin-perl-lib ]; then
	echo "You're missing the darwin-perl-lib directory, did you run the create-darwin-perl-lib_fromCPAN.pl script?"
	exit 1;
fi

if [ -x $OCSNG_PATH ]; then
	echo "removing old $OCSNG_PATH"
        sudo rm -R -f $OCSNG_PATH
fi

if [ -x package-root ]; then
	echo 'removing old package-root'
	sudo rm -R -f package-root
fi

echo "Building OS X App"
cd ocsng_app-xcode/
xcodebuild
cp -R ./build/UninstalledProducts/OCSNG.app ../
xcodebuild clean
cd ../
mkdir $OCSNG_PATH/Contents/Resources/lib

echo "Creating default config"
cp ../../etc/ocsinventory-agent/modules.conf ./modules.conf

echo "server=http://inventory/ocsinventory" > ./ocsinventory-agent.cfg
echo "tag=DEFAULT" >> ./ocsinventory-agent.cfg
echo "logfile=/var/log/ocsng.log" >> ./ocsinventory-agent.cfg
echo "delaytime=30" >> ./ocsinventory-agent.cfg

echo 'Touching cacert.pem'
echo "Make sure you replace me with your real cacert.pem" > cacert.pem

echo 'creating package-root for building .pkg under'
mkdir -p ./package-root/Applications

echo "Buidling unified source"
cp ./$PATCHES_PATH/Download-Darwin.pm.patch ../../
cd ../../
echo "Patching Download.pm for darwin use"
patch -N ./lib/Ocsinventory/Agent/Option/Download.pm ./Download-Darwin.pm.patch

echo 'removing non-MacOS/Generic backend modules'
cd ./lib/Ocsinventory/Agent/Backend/OS/
rm -R -f `ls -l | grep -v MacOS | grep -v CVS | grep -v Generic`
cd ../../../../../

echo "Building Makefile.pl...."
perl Makefile.PL
make
cp -R blib/lib ./$TOOLS_PATH/$OCSNG_PATH/Contents/Resources
cp ocsinventory-agent ./$TOOLS_PATH/
make clean

echo 'patching main perl script for OS X'
cd ./$TOOLS_PATH/
patch -N ./ocsinventory-agent ./$PATCHES_PATH/ocsinventory-agent-darwin.patch
cp ocsinventory-agent $OCSNG_PATH/Contents/Resources/

echo 'copying down darwin-dep libs'
cp -R darwin-perl-lib/ $OCSNG_PATH/Contents/Resources/lib/

# we're setting the default permissions with those we use in system_scripts/dscl-adduser.sh script, if you change those, change this
sudo chown -R 3995:3995 $OCSNG_PATH
sudo chmod -R o-w,u-w $OCSNG_PATH

echo 'copying .app to package-root'
sudo cp -R $OCSNG_PATH ./package-root/Applications/

# we're setting the default permissions with those we use in system_scripts/dscl-adduser.sh script, if you change those, change this
sudo chown -R 3995:3995 ./package-root/Applications/$OCSNG_PATH
sudo chmod -R o-rwx,u-w ./package-root/Applications/$OCSNG_PATH

echo 'setting default permissions on ./package-root/Applications'
sudo chown root:admin ./package-root/Applications
sudo chmod 775 ./package-root/Applications

# package maker might spit out some permissions errors if the app or it's folders are on your system already, this is usually OK, read them to make sure
echo "building package"
sudo rm -R -f ./OCSNG.pkg
sudo /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -build -proj OCSNG.pmproj -p ./OCSNG.pkg

FILES="Agent_MacOSX.packproj README INSTALL ver launchfiles OCSNG.pkg scripts ocsinventory-agent.cfg modules.conf cacert.pem"

mkdir Agent-MacOSX
cp -R $FILES Agent-MacOSX/
zip -r Agent-MacOSX Agent-MacOSX/
rm -R -f Agent-MacOSX/
echo "done"
