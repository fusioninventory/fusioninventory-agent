package FusionInventory::Agent::Task::Inventory::OS::AIX::Sounds;
use strict;

sub isInventoryEnabled {can_run("lsdev")}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};
  
	for(`lsdev -Cc adapter -F 'name:type:description'`){
		if(/audio/i){
			if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
			 $inventory->addSound({
	  			'DESCRIPTION'  => $3,
	  			'MANUFACTURER' => $2,
	  			'NAME'     => $1,
			});
			}
		}
	} 
}
1
