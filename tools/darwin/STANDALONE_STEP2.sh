#!/bin/bash

# package maker might spit out some permissions errors if the app or it's folders are on your system already, this is usually OK, read them to make sure 
echo "building package"
sudo rm -R -f ./OCSNG.pkg
sudo /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -build -proj OCSNG.pmproj -p ./OCSNG.pkg

FILES="INSTALL.txt ver 10_3_9-startup org.ocsng.agent.plist OCSNG.pkg installer-darwin.sh uninstall-darwin.sh dscl-adduser.sh dscl-remove-user.sh ocsinventory-agent.cfg modules.conf cacert.pem"

#echo "taring up package and installer files"
#tar -zvcf Agent-MacOSX.tar.gz --exclude=CVS ver 10_3_9-startup/ org.ocsng.agent.plist OCSNG.pkg installer-darwin.sh uninstall-darwin.sh dscl-adduser.sh dscl-remove-user.sh ocsinventory-agent.cfg modules.conf cacert.pem

#zip -r Agent-MacOSX ver org.ocsng.agent.plist OCSNG.pkg installer-darwin.sh uninstall-darwin.sh dscl-adduser.sh dscl-remove-user.sh ocsinventory-agent.cfg modules.conf cacert.pem

mkdir Agent-MacOSX
cp -R $FILES Agent-MacOSX/
zip -r Agent-MacOSX Agent-MacOSX/
rm -R -f Agent-MacOSX/
echo "done"
