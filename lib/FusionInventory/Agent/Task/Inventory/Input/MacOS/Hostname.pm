package FusionInventory::Agent::Task::Inventory::Input::MacOS::Hostname;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        canLoad("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPSoftwareDataType');
    return unless ref $info eq 'HASH';

    my $hostname = $info->{'System Software Overview'}->{'Computer Name'};

    $inventory->setHardware({
        NAME => $hostname
    }) if $hostname;
}

1;
