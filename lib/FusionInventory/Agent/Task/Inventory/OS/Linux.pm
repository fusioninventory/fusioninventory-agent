package FusionInventory::Agent::Task::Inventory::OS::Linux;

use strict;
use warnings;
use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME eq 'linux';
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    chomp (my $osversion = `uname -r`);

    my ($last_user, $last_date);
    my @query = `last -R`;
    my $last = $query[0]; 
    if ($last =~ /^(\S+) \s+ \S+ \s+ (\S+ \s+ \S+ \s+ \S+ \s+ \S+)/x ) {
        $last_user = $1;
        $last_date = $2;
    }

    # This will probably be overwritten by a Linux::Distro module.
    $inventory->setHardware({
        OSNAME             => "Linux",
        OSCOMMENTS         => "Unknown Linux distribution",
        OSVERSION          => $osversion,
        LASTLOGGEDUSER     => $last_user,
        DATELASTLOGGEDUSER => $last_date
    });
}

1;
