package FusionInventory::Agent::Task::Inventory::OS::HPUX;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Backend::OS::Generic"];

sub isEnabled  {
    return $OSNAME eq 'hpux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Operating system informations
    my $OSVersion = getFirstLine(command => 'uname -v');
    my $OSRelease = getFirstLine(command => 'uname -r');
    my $OSLicense = getFirstLine(command => 'uname -l');

    $inventory->setHardware({
        OSNAME     => 'HP-UX',
        OSVERSION  => $OSVersion . ' ' . $OSLicense,
        OSCOMMENTS => $OSRelease,
    });

    $inventory->setOS({
        NAME                 => "HP-UX",
        VERSION              => $OSRelease,
        KERNEL_VERSION       => $OSRelease,
#        FULL_NAME            => TODO 
    });
}

1;
