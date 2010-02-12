package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging;

use strict;

sub isInventoryEnabled {
  my $params = shift;
  
  # Do not run an package inventory if there is the --nosoft parameter
  return if ($params->{config}->{nosoftware});
   
  1;
}

1;
