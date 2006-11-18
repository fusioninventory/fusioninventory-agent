package Ocsinventory::Agent::Backend::OS::POSIX;
use strict;

sub check {
	my $r;
	$r = 1 if $^O =~ /^(linux|aix|solaris|freebsd|netbsd|openbsd)$/;
	$r;
}

sub run {
	my $h = shift;

	chomp(my $OSVersion =`uname -r`);
	chomp(my $OSComment =`uname -v`);

	$h->{'CONTENT'}{'HARDWARE'}{'OSNAME'} = ['POSIX'];
	$h->{'CONTENT'}{'HARDWARE'}{'OSVERSION'} = [$OSVersion];
	# Will be overwrite by a Linux::Distro module
	$h->{'CONTENT'}{'HARDWARE'}{'OSCOMMENTS'} = ["Unknow $^O system"];
	$h->{'CONTENT'}{'HARDWARE'}{'TYPE'} = [8];
}


1;
