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
- cd ./unified_unix_agent/tools/darwin
- sh ./STANDALONE_STEP1.sh
- modify ocsinventory-agent.cfg file for your organization
- sh ./STANDALONE_STEP2.sh
- take tarbal and deploy (or modify to taste)

COPYRIGHT

See AUTHORS file. Ocsinventory-Agent is released under GNU GPL 2 licence. Portions of the Xcode project may fall under other, open licences (individual files will elaborate). The Xcode project files are not core pieces of OCSNG and are to be treated as a supplement tool for building the agent for OSX deployment.

NOTE

- Darwin tools contributed by claimid.com/saxjazman9, don't bug the core OCSNG guys with bugs and quirks... they have better things to do.

- READ THE INSTALL AND UNINSTALL SCRIPTS BEFORE DEPLOYING!!! These scripts require sudo access and will modify your system by:
  - adding users
  - adding groups
  - adding launch daemons to launchd

- Use these scripts at your own risk, I claim no responsibilty nor give any warranty that they work.

- This package works on 10.4.9 - 10.5.3 [intel and ppc], I am working on a solution for 10.3.9 since the startup infrastructure in "Jag" is slightly different then the later versions.

- This does NOT include the abilty to push downloads (yet). That functionality is still being tested.
