package FusionInventory::Agent::Task::Inventory::OS::AIX::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @lsvpd = getAllLines(command => 'lsvpd', logger => $logger);
    s/^\*// foreach (@lsvpd);

    foreach my $slot (_getSlots(
        command => 'lsdev -Cc bus -F "name:description"',
        logger  => $logger
    )) {

        my $flag = 0;
        foreach (@lsvpd) {
            if (/^AX $slot->{NAME}/) {
                $flag = 1;
                next;
            }
            next unless $flag;
            if (/^YL (.*\S)/) {
                $slot->{DESCRIPTION} = $2;
            }
            if (/^FC/) {
                last;
            }
        }

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
