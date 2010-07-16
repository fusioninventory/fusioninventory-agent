package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $memories = getMemories();

    return unless $memories;

    foreach my $memory (@$memories) {
        $inventory->addMemory($memory);
    }
}

sub getMemories {
    my ($file) = @_;

    my $infos = getInfosFromDmidecode($file);

    return unless $infos->{17};

    my ($memories, $slot);
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

        cleanUnknownValues($memory);

        push @$memories, $memory;
    }

    return $memories;
}

1;
