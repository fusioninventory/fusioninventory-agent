package Ocsinventory::Agent::Backend::OS::Linux::Sounds;
use strict;

sub check { can_run("lspci") }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`lspci`){

    if(/audio/i && /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){

      $inventory->addSounds({
	  'DESCRIPTION'  => $3,
	  'MANUFACTURER' => $2,
	  'NAME'     => $1,
	});
    
    }
  }
}
1
