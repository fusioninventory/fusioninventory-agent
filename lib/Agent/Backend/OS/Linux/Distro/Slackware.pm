package Ocsinventory::Agent::Backend::OS::Linux::Distro::Slackware;
use strict;

sub check {-f "/etc/slackware-version"}

#####
sub findRelease {
	my $v;

	open V, "</etc/slackware-version" or warn;
	chomp ($v = readline V);
	close V;
	print $v."\n";
	return "Slackware / $v";
}

sub run {
	my $h = shift;
	my $OSComment;
	chomp($OSComment =`uname -v`);

	$h->{CONTENT}{HARDWARE}{OSCOMMENTS} = findRelease()." / $OSComment";
}



1;
