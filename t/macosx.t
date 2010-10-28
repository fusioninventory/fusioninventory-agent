#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use Test::More;
use FindBin;

my %lsvfs = (
	'lsvfs-1' => 
	{
	'hfs' => 1,
	'afpfs' => 1,
	'autofs' => 1,
	'ufs' => 1,
	'nfs' => 1,
	'fdesc' => 1,
	'unionfs' => 1,
	'devfs' => 1,
	'cd9660' => 1
	}
	);

plan tests => (scalar keys %lsvfs);

foreach my $test (keys %lsvfs) {
    my $file = "$FindBin::Bin/../resources/macosx/$test";
    open my $fh, '<'.$file;
    my %results = FusionInventory::Agent::Task::Inventory::OS::BSD::Drives::getVfsFromLsvfs($fh);
    use Data::Dumper;
    print Dumper(\%results);
    is_deeply($lsvfs{$test}, \%results, $test);
}

