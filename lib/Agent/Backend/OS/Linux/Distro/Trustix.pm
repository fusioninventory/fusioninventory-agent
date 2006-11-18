package Ocsinventory::Agent::Backend::OS::Linux::Distro::Trustix;
use strict;

sub check {-f "/etc/trustix-release"}

#####
sub findRelease {
	my $v;

	open V, "</etc/trustix-release" or warn;
	chomp ($v = readline V);
	close V;
	print $v."\n";
	return "Trustix / $v";
}

sub run {
	my $h = shift;
	my $OSComment;
	chomp($OSComment =`uname -v`);

	$h->{CONTENT}{HARDWARE}{OSCOMMENTS} = findRelease()." / $OSComment";
}



1;
