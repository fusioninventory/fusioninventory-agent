package Ocsinventory::Agent::Backend::OS::AIX::Modems;
use strict;

sub check {`which lsdev 2>&1`; ($? >> 8)?0:1}

sub run {
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
