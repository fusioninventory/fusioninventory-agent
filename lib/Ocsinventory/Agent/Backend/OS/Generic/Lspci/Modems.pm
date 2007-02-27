package Ocsinventory::Agent::Backend::OS::Generic::Lspci::Modems;
use strict;

sub check {1}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`lspci`){

    if(/modem/i && /\d+\s(.+):\s*(.+)$/){
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
