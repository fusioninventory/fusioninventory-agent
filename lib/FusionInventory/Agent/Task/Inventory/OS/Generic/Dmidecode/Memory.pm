package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $memories = _getMemories($logger);

    return unless $memories;

    foreach my $memory (@$memories) {
        $inventory->addMemory($memory);
    }
}

sub _getMemories {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode($logger, $file);

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

        push @$memories, $memory;
    }

    return $memories;
}

1;
