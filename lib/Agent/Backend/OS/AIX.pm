package Ocsinventory::Agent::Backend::OS::AIX;
use strict;
sub check {
	my $r;
	$r = 1 if $^O =~ /^aix$/;
	$r;
}

sub run {
  # nothing to do yet... 
}

1;
