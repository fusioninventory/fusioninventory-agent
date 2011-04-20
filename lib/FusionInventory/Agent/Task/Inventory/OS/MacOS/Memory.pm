package FusionInventory::Agent::Task::Inventory::OS::MacOS::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isInventoryEnabled {
    return 
        -r '/usr/sbin/system_profiler';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $memories = _getMemories(logger => $logger);

    return unless $memories;

    foreach my $memory (@$memories) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemories {
    my $infos = getInfosFromSystemProfiler(@_);

    return unless $infos->{Memory};

    # the memory slot informations may appears directly under
    # 'Memory' top-level node, or under Memory/Memory Slots
    my $parent_node = $infos->{Memory}->{'Memory Slots'} ?
        $infos->{Memory}->{'Memory Slots'} :
        $infos->{Memory};

    my $memories;
    # memori
    foreach my $key (sort keys %$parent_node) {
        next unless $key =~ /DIMM(\d)/; 
        my $slot = $1;

        my $info = $parent_node->{$key};
        my $description = $info->{'Part Number'};

        # convert hexa to ascii
        if ($description && $description =~ /^0x/) {
            $description = pack 'H*', substr($description, 2);
            $description =~ s/\s*$//;
        }

        my $memory = {
            NUMSLOTS     => $slot,
            DESCRIPTION  => $description,
            CAPTION      => "Status: $info->{'Status'}",
            TYPE         => $info->{'Type'},
            SERIALNUMBER => $info->{'Serial Number'},
            SPEED        => getCanonicalSpeed($info->{'Speed'}),
            CAPACITY     => getCanonicalSize($info->{'Size'})
        };

        push @$memories, $memory;
    }

    return $memories;
}

1;
