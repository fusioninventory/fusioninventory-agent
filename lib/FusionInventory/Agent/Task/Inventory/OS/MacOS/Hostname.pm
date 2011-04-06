package FusionInventory::Agent::Task::Inventory::OS::MacOS::Hostname;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_load ("Mac::SysProfile");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $hostname;

    my $prof = Mac::SysProfile->new();
    my $nfo = $prof->gettype('SPSoftwareDataType');

    return unless(ref($nfo) eq 'HASH');

    $hostname = $nfo->{'System Software Overview'}->{'Computer Name'};

    $inventory->setHardware({
        NAME => $hostname
    }) if $hostname;
}

1;
