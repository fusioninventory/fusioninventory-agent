package FusionInventory::Agent::Task::Inventory::Win32::Storages::HP;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools::Storages::HP;

our $runMeIfTheseChecksFailed = ['FusionInventory::Agent::Task::Inventory::Linux::Storages::HpWithSmartctl'];

sub isEnabled {
    return canRun('hpacucli');
}

sub doInventory {
    HpInventory(
        path => 'hpacucli',
        @_
    );
}

1;
