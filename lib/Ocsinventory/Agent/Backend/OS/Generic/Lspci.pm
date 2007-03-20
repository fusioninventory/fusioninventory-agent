package Ocsinventory::Agent::Backend::OS::Generic::Lspci;
use strict;

sub check {
	my @pci = `lspci 2>>/dev/null`;
	return 1 if @pci;
	0
}

sub run {}
1;
