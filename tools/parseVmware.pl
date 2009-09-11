#!/usr/bin/perl -w

use strict;
use warnings;

use Data::Dumper;

my $data = {
	cpu => {},
	mem => {},
};

open VMWARECPU,"</proc/vmware/cpuinfo" or die;
foreach (<VMWARECPU>) {
	if (/^\s*(\w+)\s+(\w.*)\s*/) {
	my $key = $1;
	my @data = split(/\s+/,$2);

	print Dumper(\@data);
	$data->{cpu}->{$key} = \@data;
	#print $1." -> '".$2."'\n";
	}
}

print Dumper($data);
close VMWARECPU;
