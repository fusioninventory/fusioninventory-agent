package FusionInventory::Agent::Task::Inventory::OS::HPUX;

use strict;
use warnings;

use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Backend::OS::Generic"];

sub isInventoryEnabled  { return $OSNAME =~ /hpux/ }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $OSName;
    my $OSVersion;
    my $OSRelease;
    my $OSLicense;

    #my $uname_path          = &_get_path('uname');
    # Operating system informations
    chomp($OSName = `uname -s`);  #It should allways be "HP-UX"
    chomp($OSVersion = `uname -v`);
    chomp($OSRelease = `uname -r`);
    chomp($OSLicense = `uname -l`);

    # Last login informations
    my $LastLoggedUser;
    my $LastLogDate;
    my @query = runcmd("last");

    while ( my $tempLine = shift @query) {
        #if ( /^reboot\s+system boot/ ) { continue }  #It should never be seen above a user login entry (I hope)
        if ( $tempLine =~ /^(\S+)\s+\S+\s+(.+\d{2}:\d{2})\s+/ ) {
            $LastLoggedUser = $1;
            $LastLogDate = $2;
            last;
        }
    }

#TODO add grep `hostname` /etc/hosts


    $inventory->setHardware({
        OSNAME => $OSName,
        OSVERSION => $OSVersion . ' ' . $OSLicense,
        OSCOMMENTS => $OSRelease,
        LASTLOGGEDUSER => $LastLoggedUser,
        DATELASTLOGGEDUSER => $LastLogDate
    });

}

1;
