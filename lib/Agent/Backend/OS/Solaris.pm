package Ocsinventory::Agent::Backend::OS::Solaris;
use strict;
sub check {
	my $r;
	$r = 1 if $^O =~ /^solaris$/;
	$r;
}

sub run {
	shift;
	my $params = shift;
}


1;
