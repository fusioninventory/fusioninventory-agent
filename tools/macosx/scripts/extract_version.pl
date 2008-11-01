#!/bin/perl -w

my $FILE="./ocsinventory-agent";
open(F,$FILE);
while(<F>){
	next unless $_ =~ /^our \$VERSION = '(.*)';$/;
	print $1;
}
close(F);
