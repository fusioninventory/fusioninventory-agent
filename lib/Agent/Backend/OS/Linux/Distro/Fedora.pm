package Ocsinventory::Agent::Backend::OS::Linux::Distro::Fedora;
use strict;

sub check {-f "/etc/fedora-release"}

#####
sub findRelease {
	my $v;

	open V, "</etc/fedora-release" or warn;
	chomp ($v = readline V);
	close V;
	print $v."\n";
	return "Fedora Core / $v";
}

sub run {
	my $h = shift;
	my $OSComment;
	chomp($OSComment =`uname -v`);

	$h->{CONTENT}{HARDWARE}{OSCOMMENTS} = findRelease()." / $OSComment";
}



1;
