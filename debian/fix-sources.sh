#! /bin/sh

DEBIAN_VERSION=$( dpkg-parsechangelog -S Version | cut -d':' -f2 )

cat >lib/FusionInventory/Agent/Version.pm <<-VERSION_MODULE
	package FusionInventory::Agent::Version;
	
	use strict;
	use warnings;
	
	our \$VERSION = "$DEBIAN_VERSION";
	our \$PROVIDER = "FusionInventory";
	our \$COMMENTS = [
	    "Build platform: $(uname -nrs)",
	    "Build date: $(LANG=C date)"
	];
	
	1;
VERSION_MODULE

cat >lib/setup.pm <<-SETUP_MODULE
	package
	        setup;
	
	use strict;
	use warnings;
	use parent qw(Exporter);
	
	our @EXPORT = ('%setup');
	
	our %setup = (
	    datadir => '/usr/share/fusioninventory',
	    libdir  => '/usr/share/fusioninventory/lib',
	    vardir  => '/var/lib/fusioninventory-agent',
	);
	
	1;
SETUP_MODULE
