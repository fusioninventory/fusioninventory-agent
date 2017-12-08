package FusionInventory::Agent::Task::Inventory::Virtualization;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{virtualmachine};
    return 1;
}

use constant STATUS_RUNNING => 'running';
use constant STATUS_BLOCKED => 'blocked';
use constant STATUS_IDLE => 'idle';
use constant STATUS_PAUSED => 'paused';
use constant STATUS_SHUTDOWN => 'shutdown';
use constant STATUS_CRASHED => 'crashed';
use constant STATUS_DYING => 'dying';
use constant STATUS_OFF => 'off';

sub doInventory {
}

1;
