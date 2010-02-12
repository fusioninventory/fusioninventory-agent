package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Pacman;

sub isInventoryEnabled {can_run("pacman")}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`pacman -Q`){
      /^(\S+)\s+(\S+)/;
      my $name = $1;
      my $version = $2;
     
      $inventory->addSoftware({
      'NAME' => $name,
      'VERSION' => $version
      });
  }
}

1;
