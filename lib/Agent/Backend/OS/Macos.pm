package Ocsinventory::Agent::Backend::OS::Macos;
use strict;
sub check {
	my $r;
	$r = 1 if $^O =~ /^MacOS$/;
	$r;
}

sub run {
	shift;
	my $params = shift;
}


1;
