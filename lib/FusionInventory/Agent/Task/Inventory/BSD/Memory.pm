package FusionInventory::Agent::Task::Inventory::BSD::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{memory};
    return
        canRun('sysctl') &&
        canRun('swapctl');
};

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Swap
    my $swapSize = getFirstMatch(
        command => 'swapctl -sk',
        pattern => qr/total:\s*(\d+)/i
    );

    # RAM
    my $memorySize = getFirstLine(command => 'sysctl -n hw.physmem');
    $memorySize = $memorySize / 1024;

    $inventory->setHardware({
        MEMORY => int($memorySize / 1024),
        SWAP   => int($swapSize / 1024),
    });
}

1;
