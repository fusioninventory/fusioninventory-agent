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

    foreach my $slot (_getSlots(
        command => 'lsdev -Cc bus -F "name:description"',
        logger  => $logger
    )) {
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
        $line =~ /^(.+):(.+)/;
        my $name = $1;
        my $status = 'available';
        my $designation = $2;
        my $flag = 0;
        my $description;
        my @lsvpd = `lsvpd`;
        s/^\*// foreach (@lsvpd);
        foreach (@lsvpd){
            if ((/^AX $name/) ) {$flag=1}
            if ((/^YL (.+)/) && ($flag)){
                $description = $2;
            }
            if ((/^FC .+/) && $flag) {$flag=0;last}
        }
        push @slots, {
            DESCRIPTION => $description,
            DESIGNATION => $designation,
            NAME        => $name,
            STATUS      => $status,
        };
    }
    close $handle;

    return @slots;
}

1;
