package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::ARM;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^arm/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(file => '/proc/cpuinfo', logger => $logger);
    return unless $handle;

    my $inSystem;
    while (<$handle>) {
        if ($inSystem && /^Serial\s+:\s*(.*)/) {
            $inventory->setBios(SSN => $1);
        } elsif (/^Hardware\s+:\s*(.*)/) {
            $inventory->setBios(SMODEL => $1);
            $inSystem = 1;
        }
        close $handle;
    }
}
1;
