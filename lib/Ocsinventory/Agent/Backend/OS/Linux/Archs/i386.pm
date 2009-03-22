package Ocsinventory::Agent::Backend::OS::Linux::Archs::i386;

use strict;

use Config;

sub check { 
  return 1 if $Config{'archname'} =~ /^(i\d86|x86_64)/;
  0; 
};

1
