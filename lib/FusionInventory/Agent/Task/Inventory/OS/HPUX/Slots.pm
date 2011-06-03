package FusionInventory::Agent::Task::Inventory::OS::HPUX::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return can_run('ioscan');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $type (qw/ioa ba/) {
        foreach my $slot (_getSlots(
            command => "ioscan -kFC $type",
            logger  => $logger
        )) {
            $inventory->addEntry(
                section => 'SLOTS',
                entry   => $slot
            );
        }
    }
}

sub _getSlots {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @slots;
    while (my $line = <$handle>) {
        my @info = split(/:/, $line);
        push @slots, {
            DESCRIPTION => $info[10],
            DESIGNATION => $info[16] . " " . $info[17],
            NAME        => $info[8],
            STATUS      => "OK",
        };
    }
    close $handle;

    return @slots;
}

1;
