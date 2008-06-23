DESCRIPTION
OS X [darwin] Readme

This README will help you roll your own native OSX, OCSNG.app client for enterprise deployment.

PREREQUISITES

- XCode 3.0
- Darwin Perl dependancies [A tarball with all the PerlDep's you'll need for this to run in darwin-land, location TBD]
- OCSNG.pmproj [Apple PackageMaker binrary settings file, location TBD]
- PackageMaker

BUILDING/INSTALLING

- Check out CVS if needed
- copy the inc/ directory (might need to get it out of one of the previous releases) to unified_unix_agent
- cd ./unified_unix_agent/tools/darwin
- run the create-darwin-perl-lib_fromCPAN.pl script which will create the ~/darwin-perl-lib directory. This directory will stash a built version of all the perl libraries needed to run this client (ie: no running CPAN on the hosts you're deploying this on)
	- READ THE SCRIPT BEFORE RUNNING, some CPAN configurations are needed prior to running
	- You'll need CPAN, Perl (the development libraries for perl), so Xcode Tools (just about a full install).

- sh ./STANDALONE_STEP1.sh
- modify ocsinventory-agent.cfg file for your organization (TAG, server, logfile, etc...)
- sh ./STANDALONE_STEP2.sh
- take tarball and deploy (or modify to taste)

COPYRIGHT

See AUTHORS file. Ocsinventory-Agent is released under GNU GPL 2 licence. Portions of the Xcode project may fall under other, open licences (individual files will elaborate). The Xcode project files are not core pieces of OCSNG and are to be treated as a supplement tool for building the agent for OSX deployment.

NOTE

- Darwin tools contributed by claimid.com/saxjazman9, don't bug the core OCSNG guys with bugs and quirks... they have better things to do.

- READ THE INSTALL AND UNINSTALL SCRIPTS BEFORE DEPLOYING!!! These scripts require sudo access and will modify your system by:
  - adding users
  - adding groups
  - adding launch daemons to launchd

- Use these scripts at your own risk, I claim no responsibilty nor give any warranty that they work.

- This package works on 10.3.9 - 10.5.3 [intel and ppc], It includes some modifications when running on OS 10.3.9 [panther] since the startup infrastructure is slightly different. The changes are in the installer-darwin.sh and it autochecks for darwin release [uname -r] 7.9.0. Otherwise it does its default install (Tiger and Leopard use LaunchD).
