package Ocsinventory::Agent::Backend::OS::AIX::Modems;
use strict;

sub check {can_run("lsdev")}

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
