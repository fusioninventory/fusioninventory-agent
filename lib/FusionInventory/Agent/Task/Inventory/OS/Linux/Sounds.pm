package FusionInventory::Agent::Task::Inventory::OS::Linux::Sounds;
use strict;

sub isInventoryEnabled { can_run("lspci") }

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`lspci`){

    if(/audio/i && /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){

      $inventory->addSound({
	  'DESCRIPTION'  => $3,
	  'MANUFACTURER' => $2,
	  'NAME'     => $1,
	});
    
    }
  }
}
1
