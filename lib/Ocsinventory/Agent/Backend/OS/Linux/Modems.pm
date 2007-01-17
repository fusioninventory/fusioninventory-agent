package Ocsinventory::Agent::Backend::OS::Linux::Modems;
use strict;

sub check {
  my @pci = `lspci 2>>/dev/null`;
  return 1 if @pci;
  0
}

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
