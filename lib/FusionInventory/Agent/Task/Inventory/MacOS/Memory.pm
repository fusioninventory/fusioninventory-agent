package FusionInventory::Agent::Task::Inventory::MacOS::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{memory};
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $memory (_getMemories(logger => $logger)) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }

    my $memory = _getMemory(logger => $logger);
    $inventory->setHardware({
        MEMORY => $memory,
    });

}

sub _getMemories {
    my (%params) = @_;

    my $infos = getSystemProfilerInfos(
        type   => 'SPMemoryDataType',
        logger => $params{logger},
        file   => $params{file}
    );

    return unless $infos->{Memory};

    # the memory slot informations may appears directly under
    # 'Memory' top-level node, or under Memory/Memory Slots
    my $parent_node = $infos->{Memory}->{'Memory Slots'} ?
        $infos->{Memory}->{'Memory Slots'} :
        $infos->{Memory};

    my @memories;
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
            CAPACITY     => getCanonicalSize($info->{'Size'}, 1024)
        };

        push @memories, $memory;
    }

    return @memories;
}

sub _getMemory {
    my (%params) = @_;

    my $infos = getSystemProfilerInfos(
        type   => 'SPMemoryDataType',
        logger => $params{logger},
        file   => $params{file}
    );

    return getCanonicalSize(
        $infos->{'Hardware'}{'Hardware Overview'}{'Memory'},
        1024
    );
}

1;
