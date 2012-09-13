#!/usr/bin/perl

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use File::stat;
use Test::More tests => 4;

use FusionInventory::Agent::Logger::File;

my $failure :shared;
my $maxsize = 1; # 1MB

my $fileTemp = tempdir( CLEANUP => 0 ).'/file.log'; 
my $logger = FusionInventory::Agent::Logger::File->new(
    config => {
        'logfile'         => $fileTemp,
        'logfile-maxsize' => $maxsize,
    }
);

my $sub = sub {
    eval {
        for (my $i = 0; $i< 4000; $i++) {
            $logger->addMessage(level => 'debug', message => 'message');
        }
    };
    $failure = 1 if $EVAL_ERROR;

};

my @threads;
while (@threads < 10) {
    push @threads, threads->create($sub);
}
$_->join() foreach @threads;

my $s = stat($fileTemp);

ok($s, 'stat()');
ok(!$failure, 'flock()');
ok(! -z $fileTemp, 'log is not empty');
ok($maxsize * 1024 * 1024 > $s->size , 'logfile-maxsize');
