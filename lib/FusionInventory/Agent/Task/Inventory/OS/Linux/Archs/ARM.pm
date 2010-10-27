package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::ARM;

use strict;
use warnings;

use English qw(-no_match_vars);

use Config;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^arm/;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $handle;
    if (!open $handle, '<', '/proc/cpuinfo') {
        warn "Can't open /proc/cpuinfo: $ERRNO";
        return;
    }

    my $inSystem;
    while (<$handle>) {
        if ($inSystem && /^Serial\s+:\s*(.*)/) {
            $inventory->setBios({ SSN => $1 });
        } elsif (/^Hardware\s+:\s*(.*)/) {
            $inventory->setBios({ SMODEL => $1 });
            $inSystem = 1;
	}
	close $handle;
    }
}
1;
