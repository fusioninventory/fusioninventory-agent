package FusionInventory::Agent::Task::Inventory::OS::AIX::Modems;
use strict;

sub isInventoryEnabled {can_run("lsdev")}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  for(`lsdev -Cc adapter -F 'name:type:description'`){
    if(/modem/i && /\d+\s(.+):(.+)$/){
	  my $name = $1;
	  my $description = $2;
	  $inventory->addModems({
	  	'DESCRIPTION'  => $description,
	  	'NAME'          => $name,
	  });
    }
  }
}

1
