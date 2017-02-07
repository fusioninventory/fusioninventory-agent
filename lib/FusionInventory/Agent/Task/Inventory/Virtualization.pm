package FusionInventory::Agent::Task::Inventory::Virtualization;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{virtualmachine};
    return 1;
}

our $STATUS_RUNNING = 'running';
our $STATUS_BLOCKED = 'blocked';
our $STATUS_IDLE = 'idle';
our $STATUS_PAUSED = 'paused';
our $STATUS_SHUTDOWN = 'shutdown';
our $STATUS_CRASHED = 'crashed';
our $STATUS_DYING = 'dying';
our $STATUS_OFF = 'off';

sub doInventory {
}

1;
