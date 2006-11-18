package Ocsinventory::Agent::Backend::OS::Linux;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::POSIX"];

sub check {
	my $r;
	$r = 1 if $^O =~ /^linux$/;
	$r;
}

sub run {
	my $h = shift;


	$h->{'CONTENT'}{'HARDWARE'}{'OSNAME'} = ['Linux'];
	$h->{'CONTENT'}{'HARDWARE'}{'OSCOMMENTS'} = ["Unknow Linux distribution"];
}


1;
