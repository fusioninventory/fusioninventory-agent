package FusionInventory::Agent::Task::Inventory::OS::MacOS::Hostname;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPSoftwareDataType');
    return unless ref $info eq 'HASH';

    my $hostname = $info->{'System Software Overview'}->{'Computer Name'};

    $inventory->setHardware({
        NAME => $hostname
    }) if $hostname;
}

1;
