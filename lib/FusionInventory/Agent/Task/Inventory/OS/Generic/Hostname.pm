package FusionInventory::Agent::Task::Inventory::OS::Generic::Hostname;

use strict;
use warnings;

sub isInventoryEnabled {
  return 1 if can_load ("Sys::Hostname");
  return 1 if can_run ("hostname");
  0;
}

# Initialise the distro entry
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $hostname;

  if (can_load("Sys::Hostname")) {
    $hostname = Sys::Hostname::hostname();
  } else {
    chomp ( $hostname = `hostname` );
  }
  $hostname =~ s/\..*//; # keep just the hostname

  $inventory->setHardware ({NAME => $hostname});
}

1;
