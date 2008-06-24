#!/bin/bash

OCSNG_PATH="OCSNG.app"

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

echo "Copying default config"
cp ../../etc/default/ocsinventory-agent ./ocsinventory-agent.cfg
cp ../../etc/ocsinventory-agent/modules.conf ./modules.conf

echo 'creating package-root for building .pkg under'
mkdir -p ./package-root/Applications

echo "Buidling unified source"
cp ./Download-Darwin.pm.patch ../../
cd ../../
echo "Patching Download.pm for darwin use"
patch ./lib/Ocsinventory/Agent/Option/Download.pm ./Download-Darwin.pm.patch

echo 'removing non-MacOS/Generic backend modules'
cd ./lib/Ocsinventory/Agent/Backend/OS/
rm -R -f `ls -l | grep -v MacOS | grep -v CVS | grep -v Generic`
cd ../../../../../

echo "Building Makefile.pl...."
perl Makefile.PL
make
cp -R blib/lib ./tools/darwin/$OCSNG_PATH/Contents/Resources
cp ocsinventory-agent ./tools/darwin/
make clean

echo 'patching main perl script for OS X'
cd ./tools/darwin/
patch ocsinventory-agent ocsinventory-agent-darwin.patch
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

echo "step 1 complete, modify the ocsinventory-agent.cfg to be deployed with your agent before proceeding to step_2"
