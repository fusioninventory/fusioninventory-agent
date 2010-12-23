package FusionInventory::Agent::Task::Inventory::OS::Linux;

use strict;
use warnings;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME eq 'linux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $osversion = getFirstLine(command => 'uname -r');

    my ($last_user, $last_date);
    my $last = getFirstLine(command => 'last -R');
    if ($last =~ /^(\S+) \s+ \S+ \s+ (\S+ \s+ \S+ \s+ \S+ \s+ \S+)/x ) {
        $last_user = $1;
        $last_date = $2;
    }

    # This will probably be overwritten by a Linux::Distro module.
    $inventory->setHardware(
        OSNAME             => "Linux",
        OSCOMMENTS         => "Unknown Linux distribution",
        OSVERSION          => $osversion,
        LASTLOGGEDUSER     => $last_user,
        DATELASTLOGGEDUSER => $last_date
    );
}

1;
