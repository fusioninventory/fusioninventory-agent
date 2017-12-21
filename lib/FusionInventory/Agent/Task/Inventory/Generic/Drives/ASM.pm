package FusionInventory::Agent::Task::Inventory::Generic::Drives::ASM;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('asmcmd');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Oracle documentation:
    # see https://docs.oracle.com/cd/E11882_01/server.112/e18951/asm_util004.htm#OSTMG94549
    my $diskgroups = _getDisksGroups(
        command => "su - grid -c 'asmcmd lsdg'",
        logger  => $logger
    );

    return unless $diskgroups;

    # Add disks groups inventory as DRIVES
    foreach my $diskgroup (@{$diskgroups}) {
        my $name = $diskgroup->{NAME}
            or next;

        # Only report mounted group
        next unless ($diskgroup->{STATE} && $diskgroup->{STATE} eq 'MOUNTED');

        $inventory->addEntry(
            section => 'DRIVES',
            entry   => {
                LABEL   => $diskgroup->{NAME},
                VOLUMN  => 'diskgroup',
                TOTAL   => $diskgroup->{TOTAL},
                FREE    => $diskgroup->{FREE}
            }
        );
    }
}

sub _getDisksGroups {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @groups = ();
    my $line_count = 0;
    while (my $line = <$handle>) {
        # Cleanup line
        chomp($line);
        $line = trimWhitespace($line);

        # Logic to skip header
        $line_count ++;
        next if ($line_count == 1 && $line =~ /^State.*Name$/);

        my @infos = split(/\s+/, $line);
        next unless (@infos == 13);

        # Cleanup trailing slash on NAME
        $infos[12] =~ s|/+$||;

        # Fix total against TYPE field
        my $total = int($infos[6] || 0) - int($infos[8] || 0);
        if ($infos[1] =~ /^NORMAL|HIGH$/) {
            $total /= $infos[1] eq 'HIGH' ? 3 : 2;
        }

        push @groups, {
            NAME        => $infos[12] || 'NONAME',
            STATE       => $infos[0]  || 'UNKNOWN',
            TYPE        => $infos[1]  || 'EXTERN',
            TOTAL       => int($total),
            FREE        => int($infos[9])
        };
    }

    return \@groups;
}

1;
