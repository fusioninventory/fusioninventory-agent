#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new();

my $response = $ua->mirror(
    "http://www.linux-usb.org/usb.ids",
    "share/usb2.ids"
);
if ($response->status_line =~ /Not Modified/) {
    print "File is still up-to-date\n";
    exit(0);
}
die unless $response->is_success();
