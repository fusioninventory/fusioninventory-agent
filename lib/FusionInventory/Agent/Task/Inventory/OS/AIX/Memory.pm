package FusionInventory::Agent::Task::Inventory::OS::AIX::Memory;

use strict;
use warnings;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $memory (_getMemories()) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }

    #Memory informations
    #lsdev -Cc memory -F 'name' -t totmem
    #lsattr -EOlmem0
    my $memorySize = 0;
    my @lsdev = getAllLines(
        command => 'lsdev -Cc memory -F "name" -t totmem',
        logger  => $logger
    );
    foreach (@lsdev){
        my @lsattr = getAllLines(
            command => "lsattr -EOl $_",
            logger  => $logger
        );
        foreach (@lsattr) {
            if (! /^#/){
                # See: http://forge.fusioninventory.org/issues/399
                # TODO: the regex should be improved here
                /^(.+):(\d+)/;
                $memorySize += $2;
            }
        }
    }

    #Paging Space
    my $swapSize;
    my @grep = getAllLines(command => 'lsps -s', logger => $logger);
    foreach (@grep){
        if ( ! /^Total/){
            /^\s*(\d+)\w*\s+\d+.+/;
            $swapSize = $1;
        }
    }

    $inventory->setHardware({
        MEMORY => $memorySize,
        SWAP   => $swapSize 
    });

}

sub _getMemories {
    my ($logger) = @_;

    my @memories;
    my $memory;
    my $numslots = 0;

    # lsvpd
    my @lsvpd = getAllLines(command => 'lsvpd', logger => $logger);
    s/^\*// foreach (@lsvpd);

    foreach (@lsvpd){
        if (/^DS (Memory DIMM.*)/) {
            $memory->{DESCRIPTION} = $1;
            next;
        }
        next unless $memory;
        if (/^SZ (.*\S)/) {
            $memory->{CAPACITY} = $1;
        }
        if (/^PN (.*\S)/) {
            $memory->{TYPE} = $1;
        }
        # localisation slot dans type
        if (/^YL\s(.*\S)/) {
            $memory->{CAPTION} = "Slot " . $1;
        }
        if (/^SN (.*\S)/) {
            $memory->{SERIAL} = $1;
        }
        if (/^VK (.*\S)/) {
            $memory->{VERSION} = $1;
        }
        # On rencontre un champ FC alors c'est la fin pour ce device
        if (/^FC/) {
            $memory->{NUMSLOTS} = $numslots++;
            push @memories, $memory;
            undef $memory;
        };
    }

    # End of Loop
    # The last *FC ???????? missing
    $memory->{NUMSLOTS} = $numslots++;
    push @memories, $memory;

    return @memories;
}

1;
