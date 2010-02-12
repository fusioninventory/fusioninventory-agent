package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::BSDpkg;

sub isInventoryEnabled {can_run("pkg_info")}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`pkg_info`){
      /^(\S+)-(\d+\S*)\s+(.*)/;
      my $name = $1;
      my $version = $2;
      my $comments = $3;
      
      $inventory->addSoftware({
	  'COMMENTS' => $comments,
	  'NAME' => $name,
	  'VERSION' => $version
      });
  }
}

1;
