package Ocsinventory::Agent::Backend::OS::Generic::Packaging::Deb;

use strict;
use warnings;

sub check { can_run("dpkg") }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  
# use dpkg-query -W -f='${Package}|||${Version}\n'
  foreach(`dpkg-query -W -f='\${Package}---\${Version}---\${Installed-Size}---\${Description}\n'`) {
     if (/^(\S+)---(\S+)---(\S+)---(.*)/) {     	     	
       $inventory->addSoftware ({
         'NAME'          => $1,
         'VERSION'       => $2,
         'FILESIZE'      => $3,
         'COMMENTS'      => $4,
         'FROM'          => 'deb'
       });
    }
  }
}

1;
