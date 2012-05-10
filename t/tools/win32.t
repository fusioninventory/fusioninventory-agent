#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::Win32;

my ($code, $fd) = runCommand(command => "perl -V");
ok($code eq 0, "perl -V returns 0");
my $seemOk;
foreach (<$fd>) {
    $seemOk=1 if /Summary of my perl5/;
}
ok($seemOk eq 1, "perl -V output looks good");
($code, $fd) = runCommand(
    timeout => 1,
    command => "perl -e\"sleep 10\""
);
ok($code eq 293, "timeout=1: timeout catched");
my $command = "perl -BAD";
($code, $fd) = runCommand(
    command => $command,
    no_stderr => 1
);
ok(!defined(<$fd>), "no_stderr=1: don't catch STDERR output");
($code, $fd) = runCommand(
    command => $command,
    no_stderr => 0
);
ok(defined(<$fd>), "no_stderr=0: catch STDERR output");
