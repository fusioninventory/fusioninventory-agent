package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $memories = _getMemories($logger);

    return unless $memories;

    foreach my $memory (@$memories) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemories {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode(logger => $logger, file => $file);

    my ($memories, $slot);

    if ($infos->{17}) {

        foreach my $info (@{$infos->{17}}) {
            $slot++;

            my $memory = {
                NUMSLOTS     => $slot,
                DESCRIPTION  => $info->{'Form Factor'},
                CAPTION      => $info->{'Locator'},
                SPEED        => $info->{'Speed'},
                TYPE         => $info->{'Type'},
                SERIALNUMBER => $info->{'Serial Number'}
            };

            if ($info->{'Size'} && $info->{'Size'} =~ /^(\d+) \s MB$/x) {
                $memory->{CAPACITY} = $1;
            }

            push @$memories, $memory;
        }
    } elsif ($infos->{6}) {

        foreach my $info (@{$infos->{6}}) {
            $slot++;

            my $memory = {
                NUMSLOTS => $slot,
                TYPE     => $info->{'Type'},
            };

            if ($info->{'Installed Size'} && $info->{'Installed Size'} =~ /^(\d+)\s*(MB|Mbyte)/x) {
                $memory->{CAPACITY} = $1;
            }

            push @$memories, $memory;
        }
    }

    return $memories;
}

1;
