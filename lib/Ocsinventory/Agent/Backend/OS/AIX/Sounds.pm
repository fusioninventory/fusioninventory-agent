package Ocsinventory::Agent::Backend::OS::AIX::Sounds;
use strict;

sub check {`which lsdev 2>&1`; ($? >> 8)?0:1}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  
	for(`lsdev -Cc adapter -F 'name:type:description'`){
		if(/audio/i){
			if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
			 $inventory->addSounds({
	  			'DESCRIPTION'  => $3,
	  			'MANUFACTURER' => $2,
	  			'NAME'     => $1,
			});
			}
		}
	} 
}
1
