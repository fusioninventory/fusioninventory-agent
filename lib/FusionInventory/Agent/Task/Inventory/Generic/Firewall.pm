package FusionInventory::Agent::Task::Inventory::Generic::Firewall;

use strict;
use warnings;

use constant STATUS_ON => 'on';
use constant STATUS_OFF => 'off';

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{firewall};
    return 1;
}

sub doInventory {}

1;
