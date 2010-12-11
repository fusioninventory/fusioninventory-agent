package FusionInventory::Agent::Task::Inventory::DeviceID;

use strict;
use warnings;

sub isInventoryEnabled {
    return 1;
}

# Initialise the DeviceID. In fact this value is a bit specific since
# it generates in the main script.
sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $config    = $params{config};

    if ($config->{old_deviceid}) {
        $inventory->setHardware({ OLD_DEVICEID => $config->{old_deviceid} });
    }
    $inventory->setHardware({ DEVICEID => $config->{deviceid} });

}

1;
