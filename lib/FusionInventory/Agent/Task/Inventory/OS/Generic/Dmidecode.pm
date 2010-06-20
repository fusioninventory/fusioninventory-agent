package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

sub isInventoryEnabled {
  if ($^O !~ /MSWin/) {
    return unless -r "/dev/mem";
  }
  return unless can_run("dmidecode");

  1;
}

sub doInventory {}

1;
