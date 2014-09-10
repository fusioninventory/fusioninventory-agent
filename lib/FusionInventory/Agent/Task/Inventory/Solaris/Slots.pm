package FusionInventory::Agent::Task::Inventory::Solaris::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{slot};
    return canRun('prtdiag');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $slot (_getSlots(logger => $logger)) {
        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my $info = getPrtdiagInfos(@_);

    return $info->{slots} ? @{$info->{slots}} : ();
}

1;
