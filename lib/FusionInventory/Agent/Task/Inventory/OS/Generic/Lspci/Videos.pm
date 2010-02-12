package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;
use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`lspci`){

    if(/graphics|vga|video/i && /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){

      $inventory->addVideo({
	  'CHIPSET'  => $1,
	  'NAME'     => $2,
	});

    }
  }
}
1
