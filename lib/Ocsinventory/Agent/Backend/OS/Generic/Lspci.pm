package Ocsinventory::Agent::Backend::OS::Generic::Lspci;
use strict;

sub check {
	my $lspci=`which lspci 2>/dev/null`;
	return 0 unless( -x $lspci );
#	my @pci = `lspci 2>>/dev/null`;
#	return 1 if @pci;
	1
}

sub run {}
1;
