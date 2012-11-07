#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new();

my $response = $ua->mirror(
    "http://pciids.sourceforge.net/pci.ids",
    "share/pci.ids"
);
die unless $response->is_success();
