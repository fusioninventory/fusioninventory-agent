package FusionInventory::Agent::Task::Inventory::OS::AIX::Slots;

use strict;
use warnings;

use List::Util qw(first);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isInventoryEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @infos = getLsvpdInfos(logger => $logger);

    foreach my $slot (_getSlots(
        command => 'lsdev -Cc bus -F "name:description"',
        logger  => $logger
    )) {

        my $info = first { $_->{AX} eq $slot->{NAME} } @infos;
        $slot->{DESCRIPTION} = $info->{YL} if $info;

        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my $handle = getFileHandle(@_);
    return unless $handle;


    my @slots;
    while (my $line = <$handle>) {
        next unless $line =~ /^(.+):(.+)/;

        push @slots, {
            NAME        => $1,
            DESIGNATION => $2,
            STATUS      => 'available'
        };
    }
    close $handle;

    return @slots;
}

1;
