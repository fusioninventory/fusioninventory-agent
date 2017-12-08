#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new();

my $response = $ua->mirror(
    "http://pciids.sourceforge.net/pci.ids",
    "share/pci.ids"
);
if ($response->status_line =~ /Not Modified/) {
    print "File is still up-to-date\n";
    exit(0);
}
die unless $response->is_success();
