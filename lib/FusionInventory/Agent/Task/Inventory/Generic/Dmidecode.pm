package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools::Generic;

sub isEnabled {

    return unless getDmidecodeInfos();

}

sub doInventory {}

1;
