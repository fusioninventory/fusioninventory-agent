package Ocsinventory::Agent::Backend::OS::Linux::Distro::Redhat;
use strict;

sub check {-f "/etc/mandrake-release"}

#####
sub findRelease {
	my $v;

	open V, "</etc/redhat-release" or warn;
	chomp ($v = readline V);
	close V;
	print $v."\n";
	return "Redhat / $v";
}

sub run {
	my $h = shift;
	my $OSComment;
	chomp($OSComment =`uname -v`);

	$h->{CONTENT}{HARDWARE}{OSCOMMENTS} = findRelease()." / $OSComment";
}



1;
