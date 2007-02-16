package Ocsinventory::Agent::Backend::OS::AIX::Videos;
use strict;

sub check {`which lsdev 2>&1`; ($? >> 8)?0:1}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

 for(`lsdev -Cc adapter -F 'name:type:description'`){
		if(/graphics|vga|video/i){
			if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
				 $inventory->addVideos({
	  				'CHIPSET'  => $1,
	  				'NAME'     => $2,
				});
				
			}
		}
	}
}
1
