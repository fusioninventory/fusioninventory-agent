package FusionInventory::Agent::Task::Inventory::OS::HPUX;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Backend::OS::Generic"];

sub isInventoryEnabled  {
    return $OSNAME eq 'hpux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Operating system informations
    my $OSName    = getFirstLine(command => 'uname -s');  # It should always be "HP-UX"
    my $OSVersion = getFirstLine(command => 'uname -v');
    my $OSRelease = getFirstLine(command => 'uname -r');
    my $OSLicense = getFirstLine(command => 'uname -l');

    # Last login informations
    my ($lastUser, $lastDate) = getFirstMatch(
        command => 'last',
        pattern => qr/^(\S+)\s+\S+\s+(.+\d{2}:\d{2})\s+/
    );

#TODO add grep `hostname` /etc/hosts


    $inventory->setHardware({
        OSNAME             => $OSName,
        OSVERSION          => $OSVersion . ' ' . $OSLicense,
        OSCOMMENTS         => $OSRelease,
        LASTLOGGEDUSER     => $lastUser,
        DATELASTLOGGEDUSER => $lastDate
    });

}

1;
