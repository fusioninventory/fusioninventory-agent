#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Mail;
use File::Basename;
use File::Path qw(make_path);

my $release = shift;
die unless $release;

open CHANGES, "<Changes" or die;

my $in;
foreach my $line (<CHANGES>) {
    chomp($line);
    if ($line =~ /^$release\s+(\S.*)/) {
        my $datetime = DateTime::Format::Mail->parse_datetime($1);

        my $file = sprintf("../wiki/news/%d/%02d/%02d/fusioninventory-agent-%s.mdwn",
                $datetime->year,
                $datetime->month,
                $datetime->day,
                $release
                );
        make_path(dirname($file));
        open OUT, ">$file" or die;

        print OUT
          "[[!meta  date=\"".$datetime->ymd."\"]]\n".
          "# FusionInventory Agent $release\n".
          "".
          "The FusionInventory Agent maintainers are glad to announce the $release release.\n\n".
          "You can download the archive from [the forge](http://forge.fusioninventory.org/projects/fusioninventory-agent/files)\n".
          "or directly from [the CPAN](https://metacpan.org/release/FusionInventory-Agent)\n\n".
          "We did our best to provide a solid release, please [[contact us|/resources]] is you believe to ".
          "find something unexpected\n\n".
          "## changelog\n\n";
        $in = 1;
    } elsif ($in && $line =~ /^\d/) {
        last;
    } elsif ($in && $line =~ /^(\w.*)$/) {
        print OUT "### $1\n\n";
    } elsif ($in) {
        print OUT $line."\n";
    }
}
