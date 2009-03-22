package Ocsinventory::Agent::Backend::OS::Linux::Archs::Alpha;

use strict;

use Config;

sub check { 
  return 1 if $Config{'archname'} =~ /^alpha/;
  0; 
};

1
