package Ocsinventory::Agent::Backend::OS::POSIX;
use strict;

sub check {
	my $r;
	$r = 1 if $^O =~ /^(linux|aix|solaris|freebsd|netbsd|openbsd)$/;
	$r;
}

sub run {
  my $inventory = shift;

	chomp(my $OSVersion =`uname -r`);
	chomp(my $OSComment =`uname -v`);

	# Will be overwrite by a more specific module
	$inventory->setHardware({
      OSNAME => "POSIX OS",
      OSVERSION => $OSVersion,
      OSCOMMENTS => "Unknow $^O system",
      TYPE => 8,
    });
}


1;
