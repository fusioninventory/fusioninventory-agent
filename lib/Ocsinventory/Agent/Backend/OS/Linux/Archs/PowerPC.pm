package Ocsinventory::Agent::Backend::OS::Linux::Archs::PowerPC;

use strict;

use Config;

sub check { 
  return 1 if $Config{'archname'} =~ /^(ppc|powerpc)/;
  0; 
};

1
