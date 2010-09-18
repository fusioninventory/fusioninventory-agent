package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {

    return unless can_run("dmidecode");

    my @output = `dmidecode`;
    return @output > 10;
}

sub doInventory {}

1;
