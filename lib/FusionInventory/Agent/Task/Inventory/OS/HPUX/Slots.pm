package FusionInventory::Agent::Task::Inventory::OS::HPUX::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('ioscan');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $type (qw/ioa ba/) {
        foreach my $slot (_getSlots(
            command => "ioscan -kFC $type| cut -d ':' -f 9,11,17,18",
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
        next unless $line =~ /(\S+):(\S+):(\S+):(.+)/;
        push @slots, {
            DESCRIPTION => $2,
            DESIGNATION => "$3 $4",
            NAME        => $1,
            STATUS      => "OK",
        };
    }
    close $handle;

    return @slots;
}

1;
