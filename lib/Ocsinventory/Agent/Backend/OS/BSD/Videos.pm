package Ocsinventory::Agent::Backend::OS::BSD::Videos;
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

    if(/graphics|vga|video/i && /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){

      $inventory->addVideos({
	  'CHIPSET'  => $1,
	  'NAME'     => $2,
	});

    }
  }
}
1
